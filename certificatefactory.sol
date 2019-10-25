pragma solidity ^0.4.25;

import "./ownable.sol";

contract CertificateFactory is Ownable {
    
    event NewCertificate(uint256 id, string description, string text);
    event NewAwardee(uint256 id, uint256 hashCode, string description, string text, address owner);
    
    struct CertificateDetails {
        string description;
        string text;
    }
    
    struct AwardedCertificate {
        string description;
        string text;
        uint256 hashCode;
        address owner;
    }
    
    CertificateDetails[] public certificateDetails;
    AwardedCertificate[] public awardedCertificates;
    
    mapping (bytes32 => bool) existingCertificate;
	mapping (bytes32 => bool) certificateOwned;
    mapping (uint256 => address) public certificateToOwner;
    mapping (address => uint) ownerCertificateCount;
    
    function _createCertificate(string _description, string _text, bytes32 _hashCode) internal {
        require(existingCertificate[_hashCode] == false);
        uint256 id = certificateDetails.push(CertificateDetails(_description, _text)) - 1;
        existingCertificate[_hashCode] = true;
        emit NewCertificate(id, _description, _text);
    }
    
    function createCertificate(string _description, string _text) external onlyOwner {
        bytes32 hashCode = keccak256(abi.encode(_description, _text));
        _createCertificate(_description, _text, hashCode);
    }
    
    function _awardCerticate(string _description, string _text, uint256 _hashCode, address _owner) internal {
        require(_isValid(_description, _text));
		bytes32 hashCode = keccak256(abi.encode(_description, _text, _owner));
		require(certificateOwned[hashCode] == false);
        uint id = awardedCertificates.push(AwardedCertificate(_description, _text, _hashCode, _owner)) - 1;
        certificateToOwner[id] = _owner;
        ownerCertificateCount[_owner]++;
        certificateOwned[hashCode] = true;
        emit NewAwardee(id, _hashCode, _description, _text, _owner);
    }
    
    function awardCertificate(uint256 _code, uint256 _hashCode, address _owner) external onlyOwner {
         CertificateDetails storage myCertificateDetails = certificateDetails[_code];
         _awardCerticate(myCertificateDetails.description, myCertificateDetails.text, _hashCode, _owner);
    }
    
    function _isValid(string _description, string _text) internal pure returns (bool) {
        return (keccak256(abi.encode(_description, _text)) !=  keccak256(abi.encode("","")));
    }
}