def format_event(event):
    return {
        "txHash": event["args"]["txHash"].hex(),
        "relayer": event["args"]["relayer"],
        "timestamp": int(event["args"]["timestamp"])
    }
