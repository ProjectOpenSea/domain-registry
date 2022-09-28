pragma solidity ^0.8.17;

import "./interfaces/DomainRegistryInterface.sol";

/**
 * @title  DomainRegistry
 * @author stephankmin, 0age
 * @notice DomainRegistry is a public reverse registry of tags (hash values appended to
 *         the salt and/or fulfillment calldata of Seaport orders) and their corresponding domains (keys).
 *         Users can look up a tag from a Seaport order in the registry to find its registered domains.
 */
contract DomainRegistry is DomainRegistryInterface {
    // Returns an array of registered domains for an input tag.
    mapping(bytes4 => string[]) private registry;

    // Returns true if the domain has already been registered.
    mapping(string => bool) private hasDomainBeenRegistered;

    constructor() {}

    /**
     * @notice Hash the domain and insert it in the registry.
     *
     * @param domain A string domain to be hashed and inserted into the registry.
     *
     * @return tag The hash of the domain.
     */
    function setDomain(string calldata domain) external returns (bytes4 tag) {
        // Revert if the domain has already been registered.
        if (hasDomainBeenRegistered[domain]) {
            revert DomainAlreadyRegistered(domain);
        }

        // Set the domain as having been registered.
        hasDomainBeenRegistered[domain] = true;

        // Create the tag by hashing the string domain.
        tag = bytes4(keccak256(abi.encode(domain)));

        // Find the index at which to insert the domain in the registry's domain array.
        uint256 index = registry[tag].length;

        // Append the domain to the array of domains in the registry.
        registry[tag][index] = domain;

        // Emit an event signaling the domain has been registered.
        emit DomainRegistered(domain, tag, index);
    }

    /**
     * @notice Get the array of registered domains that are keys for the tag hash value.
     *
     * @param tag The tag to get the registered domains for.
     *
     * @return domains The array of registered domains corresponding to the tag.
     */
    function getDomains(bytes4 tag)
        external
        view
        returns (string[] memory domains)
    {
        // Return the string array of registered domains that hash to the input tag.
        return registry[tag];
    }

    /**
     * @notice Get the total number of domains registered for a specific tag.
     *
     * @param tag The tag to get the total number of registered domains for.
     *
     * @return totalDomains The number of registered domains corresponding to the tag.
     */
    function getTotalDomains(bytes4 tag)
        external
        view
        returns (uint256 totalDomains)
    {
        // Return the total number of registered domains that hash to the input tag.
        return registry[tag].length;
    }

    /**
     * @notice Get the domain for a specific tag at a specific index.
     *
     * @param tag   The key value tag to pass into the registry mapping.
     * @param index The index to pass into the array of domains returned by the registry.
     *
     * @return domain The domain for the given tag and array index.
     */
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

        // Return the domain for the given tag at the given index.
        return registry[tag][index];
    }
}
