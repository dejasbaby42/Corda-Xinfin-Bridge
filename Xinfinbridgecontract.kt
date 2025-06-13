package com.template.contracts

import com.template.states.XinFinTransactionState
import net.corda.core.contracts.*
import net.corda.core.transactions.LedgerTransaction

class XinFinBridgeContract : Contract {
    companion object {
        const val ID = "com.template.contracts.XinFinBridgeContract"
    }

    override fun verify(tx: LedgerTransaction) {
        val command = tx.commands.requireSingleCommand<Commands>()
        when (command.value) {
            is Commands.Relay -> verifyRelay(tx)
            else -> throw IllegalArgumentException("Unsupported command")
        }
    }

    private fun verifyRelay(tx: LedgerTransaction) {
        require(tx.inputStates.isEmpty()) { "No input states should be consumed" }
        require(tx.outputStates.size == 1) { "Only one output state is allowed" }

        val outState = tx.outputsOfType<XinFinTransactionState>().single()

        require(outState.amount.quantity > 0) { "Amount must be greater than zero" }
        require(outState.sender != outState.receiver) { "Sender and receiver must be different" }
        require(outState.referenceId.isNotBlank()) { "Reference ID must not be empty" }
    }

    interface Commands : CommandData {
        class Relay : Commands
    }
}
