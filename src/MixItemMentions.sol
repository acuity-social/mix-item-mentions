pragma solidity ^0.5.11;

import "mix-item-store/MixItemStoreInterface.sol";


contract MixItemMentions {

    /**
     * @dev Mapping of itemId to array of account addresses.
     */
    mapping (bytes32 => address[]) itemIdMentionAccounts;

    /**
     * @dev Mapping of account address to array of itemIds.
     */
    mapping (address => bytes32[]) accountMentionItemIds;

    /**
     * @dev An item has been added to an account
     * @param account Address of the account being mentioned.
     * @param itemId itemId of the item mentioning the account.
     * @param i Index of the new item.
     */
    event AddItem(address account, bytes32 indexed itemId, uint i);

    /**
     * @dev Revert if a specific account mention does not exist.
     * @param account Address of the account.
     * @param i Index of the mention.
     */
    modifier accountMentionExists(address account, uint i) {
        require (i < accountMentionItemIds[account].length, "Account mention does not exist.");
        _;
    }

    /**
     * @dev Add an item to a topic. The item must not exist yet.
     * @param account Account to mention.
     * @param itemStore The ItemStore contract that will contain the item.
     * @param nonce The nonce that will be used to create the item.
     */
    function addItem(address account, MixItemStoreInterface itemStore, bytes32 nonce) external{
        // Get the itemId. Ensure it does not exist.
        bytes32 itemId = itemStore.getNewItemId(msg.sender, nonce);
        // Ensure the item does not have too many mentions.
        require (itemIdMentionAccounts[itemId].length < 20, "Item cannot have more than 20 mentions.");
        // Store mappings.
        accountMentionItemIds[account].push(itemId);
        itemIdMentionAccounts[itemId].push(account);
        // Log the event.
        emit AddItem(account, itemId, accountMentionItemIds[account].length -1);
    }

    /**
     * @dev Get the number of mentions an account has.
     * @param account Address of the account.
     * @return The number of items.
     */
    function getMentionItemCount(address account) external view returns (uint) {
        return accountMentionItemIds[account].length;
    }

    /**
     * @dev Get a specific topic item.
     * @param account Address of the account.
     * @param i Index of the item.
     * @return itemId itemId of the topic item.
     */
    function getMentionItem(address account, uint i) external view accountMentionExists(account, i) returns (bytes32) {
        return accountMentionItemIds[account][i];
    }

    /**
     * @dev Get the all of a topic's itemIds.
     * @param account Address of the account.
     * @return The itemIds.
     */
    function getAllMentionItems(address account) external view returns (bytes32[] memory) {
        return accountMentionItemIds[account];
    }

    /**
     * @dev Query a topic's itemIds.
     * @param account Address of the account.
     * @param offset Index of the first itemId to retreive.
     * @param limit Maximum number of itemIds to retrieve.
     * @return The itemIds.
     */
    function getMentionItemsByQuery(address account, uint offset, uint limit) external view returns (bytes32[] memory itemIds) {
        // Get topic itemIds.
        bytes32[] storage mentionItemIds = accountMentionItemIds[account];
        // Check if offset is beyond the end of the array.
        if (offset >= mentionItemIds.length) {
            return new bytes32[](0);
        }
        // Check how many itemIds we can retrieve.
        uint _limit;
        if (offset + limit > mentionItemIds.length) {
            _limit = mentionItemIds.length - offset;
        }
        else {
            _limit = limit;
        }
        // Allocate memory array.
        itemIds = new bytes32[](_limit);
        // Populate memory array.
        for (uint i = 0; i < _limit; i++) {
            itemIds[i] = mentionItemIds[offset + i];
        }
    }

    /**
     * @dev Get the number of topics an item has.
     * @param itemId itemId of the item.
     * @return The number of topics.
     */
    function getItemMentionCount(bytes32 itemId) external view returns (uint) {
        return itemIdMentionAccounts[itemId].length;
    }

    /**
     * @dev Get the topics for an item.
     * @param itemId itemId of the item.
     * @return The topics.
     */
    function getItemMentions(bytes32 itemId) external view returns (address[] memory) {
        return itemIdMentionAccounts[itemId];
    }

}
