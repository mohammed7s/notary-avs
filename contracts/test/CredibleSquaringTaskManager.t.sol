// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "../src/NotaryServiceManager.sol" as incsqsm;
import {NotaryTaskManager} from "../src/NotaryTaskManager.sol";
import {INotaryTaskManager} from "../src/INotaryTaskManager.sol";
import {BLSMockAVSDeployer} from "@eigenlayer-middleware/test/utils/BLSMockAVSDeployer.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract NotaryTaskManagerTest is BLSMockAVSDeployer {
    incsqsm.NotaryServiceManager sm;
    incsqsm.NotaryServiceManager smImplementation;
    NotaryTaskManager tm;
    NotaryTaskManager tmImplementation;

    uint32 public constant TASK_RESPONSE_WINDOW_BLOCK = 30;
    address aggregator =
        address(uint160(uint256(keccak256(abi.encodePacked("aggregator")))));
    address generator =
        address(uint160(uint256(keccak256(abi.encodePacked("generator")))));

    function setUp() public {
        _setUpBLSMockAVSDeployer();

        tmImplementation = new NotaryTaskManager(
            incsqsm.IRegistryCoordinator(address(registryCoordinator)),
            TASK_RESPONSE_WINDOW_BLOCK
        );

        // Third, upgrade the proxy contracts to use the correct implementation contracts and initialize them.
        tm = NotaryTaskManager(
            address(
                new TransparentUpgradeableProxy(
                    address(tmImplementation),
                    address(proxyAdmin),
                    abi.encodeWithSelector(
                        tm.initialize.selector,
                        pauserRegistry,
                        registryCoordinatorOwner,
                        aggregator,
                        generator
                    )
                )
            )
        );
    }

    function testCreateNewTask() public {
        INotaryTaskManager.TLSNReq memory tlsnReqSample = INotaryTaskManager.TLSNReq(2, "0xsdffds");
        bytes memory quorumNumbers = new bytes(0);
        cheats.prank(generator, generator);
        tm.createNewTask(tlsnReqSample, 100, quorumNumbers);
        assertEq(tm.latestTaskNum(), 1);
    }
}
