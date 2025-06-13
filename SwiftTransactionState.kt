package com.template.states

import com.template.contracts.SWIFTContract
import net.corda.core.contracts.*
import net.corda.core.identity.Party
import net.corda.core.serialization.CordaSerializable
import java.time.Instant
import java.util.*

@BelongsToContract(SWIFTContract::class)
@CordaSerializable
data class SWIFTTransactionState(
    val senderBank: Party,
    val receiverBank: Party,
    val amount: Amount<Currency>,
    val currencyCode: String,
    val swiftCode: String,
    val messageType: String, // e.g., MT103, MT202
    val externalReferenceId: String,
    val issuedAt: Instant,
    override val linearId: UniqueIdentifier = UniqueIdentifier()
) : LinearState {
    override val participants: List<Party>
        get() = listOf(senderBank, receiverBank)
}
