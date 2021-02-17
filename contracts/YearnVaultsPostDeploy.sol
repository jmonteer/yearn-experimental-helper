// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.12;

interface IVault {
    function addStrategy(address strategy, uint debtRatio, uint minDebtPerHarvest, uint maxDebtPerHarvest, uint performanceFee) external;
    function setDepositLimit(uint limit) external;
    function setManagementFee(uint fee) external;
    function setGovernance(address governance) external;
}

interface IStrategy {
    function setKeeper(address _keeper) external; 
    function setRewards(address _rewards) external;
    function setProfitFactor(uint _profitFactor) external;
    function setDebtThreshold(uint _debtThreshold) external;
    function setMaxReportDelay(uint _delay) external;
}

interface IKeep3rManager {
    function addStrategy(address _strategy, uint _requiredHarvest, uint _requiredTend);
}

contract YVPostDeploy {
    address public immutable sharer;
    address public immutable dev_ms;
    address public immutable keep3r_manager; 

    constructor(address _dev_ms, address _keep3r_manager, address _sharer) {
        keep3r_manager = _keep3r_manager;
        dev_ms = _dev_ms;
        sharer = _sharer;
    }

    // set up Vault and Strategy pre Manual Phase / pre first deposit
    function setUpVaultAndStrategy(IVault vault, IStrategy strategy, uint debtRatio, uint rateLimit, uint wantDepositLimit) external {
        // require governance of vault?
        // require governance of strategy?

        // add Strategy to vault 
        vault.addStrategy(address(strategy), debtRatio, rateLimit, 1000);

        //set deposit limit
        vault.setDepositLimit(wantDepositLimit);

        // setKeep3r // keep3r_manager = 0x13dAda6157Fee283723c0254F43FF1FdADe4EEd6
        strategy.setKeeper(keep3r_manager);
        
        // set Rewards
        strategy.setRewards(sharer);

        // set management fees to 0
        vault.setManagementFee(0);

        // set governance // dev_ms = ‘0x846e211e8ba920B353FB717631C015cf04061Cc9’
        // question: intermediate governance?
        vault.setGovernance(dev_ms);
    }

    // sets up keep3r with right params observed during manual phase
    function setUpKeep3r(IStrategy strategy, uint profitFactor, uint debtThreshold, uint maxReportDelay, uint requiredHarvest, uint requiredTend) external {
        strategy.setProfitFactor(profitFactor);

        strategy.setDebtThreshold(debtThreshold);

        strategy.setMaxReportDelay(maxReportDelay);

        IKeep3rManager(keep3r_manager).addStrategy(strategy, requiredHarvest, requiredTed);
    }

    // scaling up
    function testInProd(IVault vault, uint managementFee, uint wantDepositLimit, address ychadGovernance) external {
        vault.setDepositLimit(wantDepositLimit);

        vault.setManagementFee(managementFee);

        vault.setGovernance(ychadGovernance);
    }
}