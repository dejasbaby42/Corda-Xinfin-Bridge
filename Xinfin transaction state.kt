package com.template.states

import com.template.contracts.XinFinBridgeContract
import net.corda.core.contracts.*
import net.corda.core.identity.Party
import net.corda.core.serialization.CordaSerializable
import java.security.PublicKey
import java.time.Instant

@BelongsToContract(XinFinBridgeContract::class)
data class XinFinTransactionState(
    val sender: Party,
    val receiver: Party,
    val amount: Amount<Currency>,
    val referenceId: String,
    val txHash: SecureHash,
    val timestamp: Instant,
    override val linearId: UniqueIdentifier = UniqueIdentifier()
) : LinearState {
    override val participants: List<Party> get() = listOf(sender, receiver)
}
