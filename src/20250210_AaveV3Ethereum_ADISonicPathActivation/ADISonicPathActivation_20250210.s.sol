// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {EthereumScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';

address constant PAYLOAD = address(0x41FE455778201FB3AC7E41a7b2B4ffC90F08035e);

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20250210_AaveV3Ethereum_ADISonicPathActivation/ADISonicPathActivation_20250210.s.sol:DeployEthereum chain=mainnet
 * verify-command: FOUNDRY_PROFILE=mainnet npx catapulta-verify -b broadcast/ADISonicPathActivation_20250210.s.sol/1/run-latest.json
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(PAYLOAD);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Create Proposal
 * command: make deploy-ledger contract=src/20250210_AaveV3Ethereum_ADISonicPathActivation/ADISonicPathActivation_20250210.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](1);

    // compose actions for validation
    IPayloadsControllerCore.ExecutionAction[]
      memory actionsEthereum = new IPayloadsControllerCore.ExecutionAction[](1);
    actionsEthereum[0] = GovV3Helpers.buildAction(PAYLOAD);

    payloads[0] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereum);

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_POL,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20250210_AaveV3Ethereum_ADISonicPathActivation/ADISonicPathActivation.md'
      )
    );
  }
}
