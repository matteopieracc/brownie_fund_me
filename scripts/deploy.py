from brownie import FundMe, MockV3Aggregator, network, config


# this is possible because there is __init__.py (is a module)
from scripts.helpful_scripts import (
    get_account,
    deploy_mocks,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)

# if we're on a persistent network like rinkeby use this associated address
# otherwise deploy mocks
def deploy_fund_me():
    account = get_account()
    print(account)
    # deploy but need to pass the pricefeed address of the network used
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        deploy_mocks()
        # we use the most recently deployed mockv3aggregator
        price_feed_address = MockV3Aggregator[-1].address

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deployed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
