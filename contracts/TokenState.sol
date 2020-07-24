pragma solidity ^0.5.16;

// Inheritance
import "./Owned.sol";
import "./State.sol";


// https://docs.synthetix.io/contracts/TokenState
contract TokenState is Owned, State {
    /* ERC20 fields. */
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    /* ERC777 fields. */
    address[] public defaultOperatorsArray;
    mapping(address => bool) public defaultOperators;

    // For each account, a mapping of its operators and revoked default operators.
    mapping(address => mapping(address => bool)) public operators;
    mapping(address => mapping(address => bool)) public revokedDefaultOperators;

    constructor(address _owner, address _associatedContract) public Owned(_owner) State(_associatedContract) {}

    /* ========== GETTERS ========== */
    /**
     * @dev See {IERC777-defaultOperators}.
     */
    function getDefaultOperators() view external onlyAssociatedContract returns (address[] memory) {
        return defaultOperatorsArray;
    }

    /* ========== SETTERS ========== */

    /**
     * @notice Set ERC20 allowance.
     * @dev Only the associated contract may call this.
     * @param tokenOwner The authorising party.
     * @param spender The authorised party.
     * @param value The total value the authorised party may spend on the
     * authorising party's behalf.
     */
    function setAllowance(
        address tokenOwner,
        address spender,
        uint value
    ) external onlyAssociatedContract {
        allowance[tokenOwner][spender] = value;
    }

    /**
     * @notice Set the balance in a given account
     * @dev Only the associated contract may call this.
     * @param account The account whose value to set.
     * @param value The new balance of the given account.
     */
    function setBalanceOf(address account, uint value) external onlyAssociatedContract {
        balanceOf[account] = value;
    }

    function setDefaultOperator(address account) external onlyAssociatedContract {
        if (!defaultOperators[account]) {
            defaultOperators[account] = true;
            defaultOperatorsArray.push(account);
        }
    }

    function setOperator(address account, address operator) external onlyAssociatedContract {
        if (defaultOperators[operator]) {
            delete revokedDefaultOperators[account][operator];
        } else {
            operators[account][operator] = true;
        }
    }

    function deleteOperator(address account, address operator) external onlyAssociatedContract {
         if (TokenState.defaultOperators[operator]) {
            TokenState.revokedDefaultOperators[account][operator] = true;
        } else {
            delete TokenState.operators[account][operator];
        }
    }
}
