// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TinyBlock {

  struct TinyUrl {
    address owner;
    string code;
    string url;
  }

  mapping(string => uint) public codeToUrlIndex;
  mapping(address => uint[]) public userUrlIndexes;
  TinyUrl[] public urls;

  string private characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  bytes private charactersBytes = bytes(characters);
  uint private currentIndex = 0;

  event Add(address indexed _user, string _code, string _url);

  function add(string memory url) external {
    string memory code = _genNextCode();
    TinyUrl memory tinyurl = TinyUrl({
      url: url,
      code: code,
      owner: msg.sender
    });
    uint curIndex = urls.length;
    urls.push(tinyurl);
    codeToUrlIndex[code] = curIndex;
    userUrlIndexes[msg.sender].push(curIndex);
    ++currentIndex;
    emit Add(msg.sender, code, url);
  }

  function getUrlFromCode(string memory code) external view returns (TinyUrl memory) {
    uint id = codeToUrlIndex[code];
    require(id < urls.length && id >= 0, "Code does not exist");
    TinyUrl memory url = urls[id];
    return url;
  }

  function length() public view returns (uint) {
    return urls.length;
  }

  function getUrlFromIndex(uint id) external view returns (TinyUrl memory) {
    require(id < urls.length && id >= 0, "Code does not exist");
    TinyUrl memory url = urls[id];
    return url;
  }

  function userUrlsLength(address user) external view returns (uint) {
    return userUrlIndexes[user].length;
  }

  function getUserUrl(address user, uint index) external view returns (TinyUrl memory) {
    uint[] memory ids = userUrlIndexes[user];
    require(ids.length > 0, "User has no urls");
    require(index < ids.length && index >= 0, "Index out of range");
    uint id = ids[index];
    return urls[id];
  }

  function getAllUserUrls(address user) external view returns (TinyUrl[] memory) {
    uint len = userUrlIndexes[user].length;
    TinyUrl[] memory userUrls = new TinyUrl[](len);
    for (uint i = 0; i < len; i++) {
      userUrls[i] = urls[userUrlIndexes[user][i]];
    }
    return userUrls;
  }

  function _genNextCode() internal view returns (string memory) {
    /*
    a-z = 26
    A-Z = 26
    0-9 = 10
    --------
          62
    */
    if (currentIndex == 0) {
      return string(abi.encodePacked(charactersBytes[0]));
    }
    uint base = 62;
    string memory result = "";
    uint value = currentIndex;
    while (value > 0) {
      uint8 remainder = uint8(value % base);
      result = string(abi.encodePacked(charactersBytes[remainder], result));
      value /= base;
    }
    return result;
  }
}
