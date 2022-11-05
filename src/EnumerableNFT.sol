// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "openzeppelin-contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract EnumerableNFT is ERC721Enumerable {
    constructor() ERC721("EnumerableNFT", "ENFT") {

    }

    function mint(uint256 tokenId) external {
        require(tokenId >= 1 && tokenId <=20, 
        "TokenID must be in range [1..20] inclusive");

        _mint(msg.sender, tokenId);
    }
}

contract NFTGame {
    IERC721Enumerable nft;

    constructor(address _addr) {
        nft = IERC721Enumerable(_addr);
    } 

    function getNumberOfPrimeNumberTokenId(address account) external view returns (uint256) {
        uint256 primes;
        for(uint i = 0; i < nft.balanceOf(account); i++) {
            uint256 tokenId = nft.tokenOfOwnerByIndex(account, i);
            if(isPrime(tokenId)) {
                primes++;
            }
        }

        return primes;
    }

    function isPrime(uint256 n) private pure returns (bool) {
        if(n == 1) {
            return false;
        }
        
        for (uint256 i = 2; i <= n/2; i++) {
            if (n % i == 0) {
                return false;
            }
        }
        return true;
    }
}