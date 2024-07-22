// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;
pragma experimental ABIEncoderV2;

import "./IKontrolCheatsBase.sol";

abstract contract KontrolCheats {
    KontrolCheatsBase public constant kevm = KontrolCheatsBase(address(uint160(uint256(keccak256("hevm cheat code")))));

    // Checks if an address matches one of the built-in addresses.
    function notBuiltinAddress(address addr) internal pure returns (bool) {
        return (addr != address(645326474426547203313410069153905908525362434349) &&
                addr != address(728815563385977040452943777879061427756277306518));
    }

    function freshUInt256() internal returns (uint256) {
        return kevm.freshUInt(32);
    }

    function freshUInt248() internal returns (uint248) {
        return uint248(kevm.freshUInt(31));
    }

    function freshUInt240() internal returns (uint240) {
        return uint240(kevm.freshUInt(30));
    }

    function freshUInt232() internal returns (uint232) {
        return uint232(kevm.freshUInt(29));
    }

    function freshUInt224() internal returns (uint224) {
        return uint224(kevm.freshUInt(28));
    }

    function freshUInt216() internal returns (uint216) {
        return uint216(kevm.freshUInt(27));
    }

    function freshUInt208() internal returns (uint208) {
        return uint208(kevm.freshUInt(26));
    }

    function freshUInt200() internal returns (uint200) {
        return uint200(kevm.freshUInt(25));
    }

    function freshUInt192() internal returns (uint192) {
        return uint192(kevm.freshUInt(24));
    }

    function freshUInt184() internal returns (uint184) {
        return uint184(kevm.freshUInt(23));
    }

    function freshUInt176() internal returns (uint176) {
        return uint176(kevm.freshUInt(22));
    }

    function freshUInt168() internal returns (uint168) {
        return uint168(kevm.freshUInt(21));
    }

    function freshUInt160() internal returns (uint160) {
        return uint160(kevm.freshUInt(20));
    }

    function freshUInt152() internal returns (uint152) {
        return uint152(kevm.freshUInt(19));
    }

    function freshUInt144() internal returns (uint144) {
        return uint144(kevm.freshUInt(18));
    }

    function freshUInt136() internal returns (uint136) {
        return uint136(kevm.freshUInt(17));
    }

    function freshUInt128() internal returns (uint128) {
        return uint128(kevm.freshUInt(16));
    }

    function freshUInt120() internal returns (uint120) {
        return uint120(kevm.freshUInt(15));
    }

    function freshUInt112() internal returns (uint112) {
        return uint112(kevm.freshUInt(14));
    }

    function freshUInt104() internal returns (uint104) {
        return uint104(kevm.freshUInt(13));
    }

    function freshUInt96() internal returns (uint96) {
        return uint96(kevm.freshUInt(12));
    }

    function freshUInt88() internal returns (uint88) {
        return uint88(kevm.freshUInt(11));
    }

    function freshUInt80() internal returns (uint80) {
        return uint80(kevm.freshUInt(10));
    }

    function freshUInt72() internal returns (uint72) {
        return uint72(kevm.freshUInt(9));
    }

    function freshUInt64() internal returns (uint64) {
        return uint64(kevm.freshUInt(8));
    }

    function freshUInt56() internal returns (uint56) {
        return uint56(kevm.freshUInt(7));
    }

    function freshUInt48() internal returns (uint48) {
        return uint48(kevm.freshUInt(6));
    }

    function freshUInt40() internal returns (uint40) {
        return uint40(kevm.freshUInt(5));
    }

    function freshUInt32() internal returns (uint32) {
        return uint32(kevm.freshUInt(4));
    }

    function freshUInt24() internal returns (uint24) {
        return uint24(kevm.freshUInt(3));
    }

    function freshUInt16() internal returns (uint16) {
        return uint16(kevm.freshUInt(2));
    }

    function freshUInt8() internal returns (uint8) {
        return uint8(kevm.freshUInt(1));
    }

    function freshAddress() internal returns (address) {
        return address(uint160(kevm.freshUInt(20)));
    }

    function freshSInt256() internal returns (int256) {
        return int256(kevm.freshUInt(32));
    }

    function freshSInt248() internal returns (int248) {
        return int248(uint248(kevm.freshUInt(31)));
    }

    function freshSInt240() internal returns (int240) {
        return int240(uint240(kevm.freshUInt(30)));
    }

    function freshSInt232() internal returns (int232) {
        return int232(uint232(kevm.freshUInt(29)));
    }

    function freshSInt224() internal returns (int224) {
        return int224(uint224(kevm.freshUInt(28)));
    }

    function freshSInt216() internal returns (int216) {
        return int216(uint216(kevm.freshUInt(27)));
    }

    function freshSInt208() internal returns (int208) {
        return int208(uint208(kevm.freshUInt(26)));
    }

    function freshSInt200() internal returns (int200) {
        return int200(uint200(kevm.freshUInt(25)));
    }

    function freshSInt192() internal returns (int192) {
        return int192(uint192(kevm.freshUInt(24)));
    }

    function freshSInt184() internal returns (int184) {
        return int184(uint184(kevm.freshUInt(23)));
    }

    function freshSInt176() internal returns (int176) {
        return int176(uint176(kevm.freshUInt(22)));
    }

    function freshSInt168() internal returns (int168) {
        return int168(uint168(kevm.freshUInt(21)));
    }

    function freshSInt160() internal returns (int160) {
        return int160(uint160(kevm.freshUInt(20)));
    }

    function freshSInt152() internal returns (int152) {
        return int152(uint152(kevm.freshUInt(19)));
    }

    function freshSInt144() internal returns (int144) {
        return int144(uint144(kevm.freshUInt(18)));
    }

    function freshSInt136() internal returns (int136) {
        return int136(uint136(kevm.freshUInt(17)));
    }

    function freshSInt128() internal returns (int128) {
        return int128(uint128(kevm.freshUInt(16)));
    }

    function freshSInt120() internal returns (int120) {
        return int120(uint120(kevm.freshUInt(15)));
    }

    function freshSInt112() internal returns (int112) {
        return int112(uint112(kevm.freshUInt(14)));
    }

    function freshSInt104() internal returns (int104) {
        return int104(uint104(kevm.freshUInt(13)));
    }

    function freshSInt96() internal returns (int96) {
        return int96(uint96(kevm.freshUInt(12)));
    }

    function freshSInt88() internal returns (int88) {
        return int88(uint88(kevm.freshUInt(11)));
    }

    function freshSInt80() internal returns (int80) {
        return int80(uint80(kevm.freshUInt(10)));
    }

    function freshSInt72() internal returns (int72) {
        return int72(uint72(kevm.freshUInt(9)));
    }

    function freshSInt64() internal returns (int64) {
        return int64(uint64(kevm.freshUInt(8)));
    }

    function freshSInt56() internal returns (int56) {
        return int56(uint56(kevm.freshUInt(7)));
    }

    function freshSInt48() internal returns (int48) {
        return int48(uint48(kevm.freshUInt(6)));
    }

    function freshSInt40() internal returns (int40) {
        return int40(uint40(kevm.freshUInt(5)));
    }

    function freshSInt32() internal returns (int32) {
        return int32(uint32(kevm.freshUInt(4)));
    }

    function freshSInt24() internal returns (int24) {
        return int24(uint24(kevm.freshUInt(3)));
    }

    function freshSInt16() internal returns (int16) {
        return int16(uint16(kevm.freshUInt(2)));
    }

    function freshSInt8() internal returns (int8) {
        return int8(uint8((kevm.freshUInt(1))));
    }
}
