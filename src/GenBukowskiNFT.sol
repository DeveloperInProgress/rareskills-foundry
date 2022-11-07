// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "openzeppelin-contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/utils/Strings.sol";

//0xd57B5794709B8a9604581A6fe666Fc416dc8A452
//Goerli

contract GenBukowskiNFT is ERC721 {

    using Strings for uint256;

    uint256 public tokenSupply = 0;
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant MINT_COST = 0;
    
    address immutable deployer;

    modifier onlyDeployer {
        require(deployer == msg.sender, "Caller is not the owner");
        _;
    }

    constructor() ERC721("Gen Bukowski", "GBW") {
        deployer = msg.sender;
    }


    function mint() external payable {
        require(tokenSupply < MAX_SUPPLY, "No more tokens available");
        require(msg.value == MINT_COST, "Incorrect price");
        
        _mint(msg.sender, tokenSupply);
        tokenSupply++;
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmcU4C8mdCa3vTi5SKgUnSzKBRzFitPyxqtJjqj3rPHDyZ/";
    }

    function withdraw() external onlyDeployer {
        payable(deployer).transfer(address(this).balance);
    }

}
