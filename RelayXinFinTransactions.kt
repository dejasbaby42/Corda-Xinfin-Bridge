package com.template.flows

import co.paralleluniverse.fibers.Suspendable
import com.template.contracts.XinFinBridgeContract
import com.template.states.XinFinTransactionState
import net.corda.core.contracts.Amount
import net.corda.core.contracts.Command
import net.corda.core.contracts.SecureHash
import net.corda.core.flows.*
import net.corda.core.identity.Party
import net.corda.core.transactions.SignedTransaction
import net.corda.core.transactions.TransactionBuilder
import net.corda.core.utilities.ProgressTracker
import java.time.Instant
import java.util.*

@InitiatingFlow
@StartableByRPC
class RelayXinFinTransactionFlow(
    private val receiver: Party,
    private val amount: Amount<Currency>,
    private val referenceId: String,
    private val txHash: SecureHash
) : FlowLogic<SignedTransaction>() {

    companion object {
        object GENERATING_TRANSACTION : ProgressTracker.Step("Generating transaction...")
        object VERIFYING_TRANSACTION : ProgressTracker.Step("Verifying transaction...")
        object SIGNING_TRANSACTION : ProgressTracker.Step("Signing transaction...")
        object FINALISING_TRANSACTION : ProgressTracker.Step("Finalising transaction...")

        fun tracker() = ProgressTracker(
            GENERATING_TRANSACTION,
            VERIFYING_TRANSACTION,
            SIGNING_TRANSACTION,
            FINALISING_TRANSACTION
        )
    }

    override val progressTracker = tracker()

    @Suspendable
    override fun call(): SignedTransaction {
        val notary = serviceHub.networkMapCache.notaryIdentities.first()
        val sender = ourIdentity

        progressTracker.currentStep = GENERATING_TRANSACTION

        val outputState = XinFinTransactionState(
            sender = sender,
            receiver = receiver,
            amount = amount,
            referenceId = referenceId,
            txHash = txHash,
            timestamp = Instant.now()
        )

        val command = Command(
            XinFinBridgeContract.Commands.Relay(),
            listOf(sender.owningKey, receiver.owningKey)
        )

        val txBuilder = TransactionBuilder(notary)
            .addOutputState(outputState, XinFinBridgeContract.ID)
            .addCommand(command)

        progressTracker.currentStep = VERIFYING_TRANSACTION
        txBuilder.verify(serviceHub)

        progressTracker.currentStep = SIGNING_TRANSACTION
        val ptx = serviceHub.signInitialTransaction(txBuilder)

        val counterpartySession = initiateFlow(receiver)

        progressTracker.currentStep = FINALISING_TRANSACTION
        return subFlow(FinalityFlow(ptx, listOf(counterpartySession)))
    }
}

@InitiatedBy(RelayXinFinTransactionFlow::class)
class RelayXinFinTransactionResponderFlow(private val counterpartySession: FlowSession) : FlowLogic<SignedTransaction>() {
    @Suspendable
    override fun call(): SignedTransaction {
        return subFlow(ReceiveFinalityFlow(counterpartySession))
    }
}
