//SPDX-License-Identifier: MIT

pragma solidity 0.8.26;


/// IMPORTS
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage, Strings} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/// ERRORS ///
///@notice error emitted when the user already has an NFT
error NebulaEvolution_AlreadyHasAnNFT();
///@notice error emitted when the NFT id is bigger than the number of NFTs minted.
error NebulaEvolution_InvalidNFTId();
///@notice error emitted when the input level is bigger than the MAX
error NebulaEvolution_ThereAreOnlySevenLevels(uint256 level);

contract NebulaEvolution is ERC721, ERC721URIStorage, AccessControl {

    /// Types Declarations ///
    using Strings for uint256;

    /// Custom Types ///
    ///@notice Struct to store the name and image of each NFT level.
    struct Star{
        string name;
        string image;
    }

    /// Constant & Immutable ///
    ///@notice variable to store the MINTER_ROLE hash
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    ///@notice variable to store the max level of a NFT
    uint256 constant TOTAL_LEVELS = 7;
    ///@notice magical number removal
    uint256 constant ONE = 1;

    /// State Variable ///
    ///@notice variable to store the tokens Id.
    uint256 private s_tokenId;

    /// Storage ///
    ///@notice mapping to store and control the level-expNeeded relation.
    mapping(uint256 level => uint256 expNeeded) public s_expPerLevel;
    ///@notice mapping to store the Struct Star holding each nft level information
    mapping(uint256 level => Star) public s_starInformation;

    /// Events ///
    ///@notice event emitted when a new NFT is minted
    event NebulaEvolution_TheGasIsFreezingABirthIsOnTheWay(uint256 tokenId);
    ///@notice event emitted when a level is updated
    event NebulaEvolution_LevelUpdated(uint256 level,  uint256 amountOfExp);
    ///@notice event emitted when a NFT metadata is updated
    event NebulaEvolution_NFTUpdated(uint256 tokenId, string finalURI);

    /**
        * @notice Constructor to initialize inherited storage variables
        * @param _name The ERC721 token name
        * @param _symbol The ERC721 token symbol
        * @param _admin the contract's owner/admin
        * @param _minter the address allowed to MINT tokens
    */
    constructor(
        string memory _name, 
        string memory _symbol,
        address _admin,
        address _minter
    ) ERC721(_name, _symbol){
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MINTER_ROLE, _minter);

        s_starInformation[1] = Star("Stelar Dust", "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/StelarDust.png");
        s_starInformation[2] = Star("Protostar", "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/Protostar.png");
        s_starInformation[3] = Star("Principal Sequence", "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/PrincipalSequence.png");
        s_starInformation[4] = Star("Red Giant", "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/RedGiant.png");
        s_starInformation[5] = Star("White Dwarf", "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/WhiteDwarf.png");
        s_starInformation[6] = Star("Supernova", "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/Supernova.png");
        s_starInformation[7] = Star("BlackHole", "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/Black%20Hole.png");
    }

    /// External ///
    /**
        *@notice external function used to mint NFTs
        *@param _user the user who must receive the minted NFT
        *@dev only the MINTER can call this functions
        *@dev One user can't have multiple NFTs per wallet
    */
    function safeMint(address _user) external onlyRole(MINTER_ROLE) returns(uint256 tokenId){
        if(balanceOf(_user) >= ONE) revert NebulaEvolution_AlreadyHasAnNFT();

        tokenId = s_tokenId;

        string memory uri = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', s_starInformation[1].name, '",'
                        '"description": "Nebula Evolution",',
                        '"image": "', s_starInformation[1].image, '",'
                        '"attributes": [',
                            '{"trait_type": "Exp",',
                            '"value": ', "0",'}',
                            ',{"trait_type": "Level",',
                            '"value": ', "1",'}',
                        ']}'
                    )
                )
            )
        );

        string memory finalURI = string(
            abi.encodePacked("data:application/json;base64,", uri)
        );

        s_tokenId = s_tokenId + 1;

        emit NebulaEvolution_TheGasIsFreezingABirthIsOnTheWay(tokenId);

        _safeMint(_user, tokenId);
        _setTokenURI(tokenId, finalURI);
    }

    /**
     * @notice external function to update NFTs
     * @param _tokenId The NFT ID
     * @param _exp The EXP amount received
     * @dev this functions must only be called by Main contract
    */
    function updateNFT(uint256 _tokenId, uint256 _exp) external onlyRole(MINTER_ROLE){
        if(_tokenId > s_tokenId) revert NebulaEvolution_InvalidNFTId();

        uint256 i = 1;
        uint256 nftLevel;

        while(i < TOTAL_LEVELS){
            if(_exp < s_expPerLevel[i]){
                nftLevel = i - 1;
                break;
            }
            ++i;
        }
        _updateNFTMetadata(_tokenId, nftLevel, _exp);
    }

    /**
        *@notice external function to update the Stars levels
        *@param _level the level to be updated
        *@param _amountOfExp the amount of exp to be updated
        *@dev this function must only be called by the admin/owner
    */
    function levelsSetter(uint256 _level, uint256 _amountOfExp) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if(_level > TOTAL_LEVELS) revert NebulaEvolution_ThereAreOnlySevenLevels(_level);

        s_expPerLevel[_level] = _amountOfExp;

        emit NebulaEvolution_LevelUpdated(_level, _amountOfExp);
    }

    /// Public ///
    ///@notice OpenZeppelin functions
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage, AccessControl) returns (bool){
        return super.supportsInterface(interfaceId);
    }
    
    ///@notice OpenZeppelin functions
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory){
        return super.tokenURI(tokenId);
    }

    /// Private ///
    /**
        *@notice private function to process METADATA updates
        *@param _tokenId the Id of the token which needs to be updated
        *@param _nftLevel the level of the NFT
        *@param _exp the total amount of experience this NFT have
    */
    function _updateNFTMetadata(uint256 _tokenId, uint256 _nftLevel, uint256 _exp) private {

        string memory uri = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', s_starInformation[_nftLevel].name, '",'
                        '"description": "Nebula Evolution",',
                        '"image": "', s_starInformation[_nftLevel].image, '",'
                        '"attributes": [',
                            ',{"trait_type": "Level",',
                            '"value": ', _nftLevel.toString(),'}',
                            '{"trait_type": "Exp",',
                            '"value": ', _exp.toString(),'}',
                        ']}'
                    )
                )
            )
        );

        // Create token URI
        string memory finalURI = string(
            abi.encodePacked("data:application/json;base64,", uri)
        );
        
        emit NebulaEvolution_NFTUpdated(_tokenId, finalURI);

        _setTokenURI(_tokenId, finalURI);
    }
}

