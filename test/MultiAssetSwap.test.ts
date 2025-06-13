it("should redeem a swap with valid preimage", async () => {
    await swap.connect(sender).initiateSwap(...);
    await swap.connect(receiver).redeemSwap(swapId, correctPreimage);
    const swapData = await swap.swaps(swapId);
    expect(swapData.withdrawn).to.equal(true);
});
