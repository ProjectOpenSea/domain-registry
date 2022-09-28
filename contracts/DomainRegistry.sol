pragma solidity ^0.8.17;

import "./interfaces/DomainRegistryInterface.sol";

contract DomainRegistry is DomainRegistryInterface {
    mapping(bytes4 => string[]) private registry;

    mapping(string => bool) private hasDomainBeenRegistered;

    error DomainAlreadyRegistered(string domain);

    error DomainIndexOutOfRange(
        bytes4 tag,
        uint256 totalDomains,
        uint256 suppliedIndex
    );

    constructor() {}

    function setDomain(string calldata domain) external returns (bytes4 tag) {
        // Revert if the domain has already been registered.
        if (hasDomainBeenRegistered[domain]) {
            revert DomainAlreadyRegistered(domain);
        }

        // Set the domain as having been registered.
        hasDomainBeenRegistered[domain] = true;

        // Create the tag by hashing the string domain.
        tag = bytes4(keccak256(abi.encode(domain)));

        // Find the index at which to insert the domain in the registry.
        uint256 index = registry[tag].length;

        // Set the domain at the index of its corresponding tag array in the registry.
        registry[tag][index] = domain;
    }

    function getDomains(bytes4 tag)
        external
        view
        returns (string[] memory domains)
    {
        // Return the string array of registered domains that hash to the input tag.
        return registry[tag];
    }

    function getTotalDomains(bytes4 tag)
        external
        view
        returns (uint256 totalDomains)
    {
        // Return the total number of registered domains that hash to the input tag.
        return registry[tag].length;
    }

    function getDomain(bytes4 tag, uint256 index)
        external
        view
        returns (string memory domain)
    {
        // Get the number of domains that have been registered for the input tag.
        uint256 totalDomains = registry[tag].length;

        // Revert if the passed in index is out of range for the array of domains corresponding to the tag.
        if (index >= totalDomains) {
            revert DomainIndexOutOfRange(tag, totalDomains, index);
        }

        // Return the domain.
        return registry[tag][index];
    }
}
