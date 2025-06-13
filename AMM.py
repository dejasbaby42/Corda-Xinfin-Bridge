import json

class AMM:
    def __init__(self, reserve_tokenA: float, reserve_tokenB: float, fee_percent: float = 0.3):
        self.tokenA = reserve_tokenA
        self.tokenB = reserve_tokenB
        self.fee = fee_percent / 100

    def get_price(self, input_amount: float, input_token: str) -> float:
        if input_token == "A":
            input_reserve = self.tokenA
            output_reserve = self.tokenB
        elif input_token == "B":
            input_reserve = self.tokenB
            output_reserve = self.tokenA
        else:
            raise ValueError("Invalid input token. Use 'A' or 'B'.")

        input_amount_with_fee = input_amount * (1 - self.fee)
        numerator = input_amount_with_fee * output_reserve
        denominator = input_reserve + input_amount_with_fee

        return numerator / denominator

    def simulate_swap(self, input_amount: float, input_token: str) -> dict:
        output_amount = self.get_price(input_amount, input_token)
        result = {
            "input_token": input_token,
            "input_amount": input_amount,
            "output_token": "B" if input_token == "A" else "A",
            "output_amount": output_amount,
            "rate": output_amount / input_amount
        }
        return result

if __name__ == "__main__":
    # Example: 10,000 of Token A and Token B in pool
    pool = AMM(reserve_tokenA=10000, reserve_tokenB=10000)

    input_amount = 100
    input_token = "A"
    swap_result = pool.simulate_swap(input_amount, input_token)

    print("🔎 Simulated Swap:")
    print(json.dumps(swap_result, indent=4))
