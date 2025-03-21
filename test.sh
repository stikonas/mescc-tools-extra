#! /bin/sh
## Copyright (C) 2017 Jeremiah Orians
## This file is part of stage0.
##
## stage0 is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## stage0 is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with stage0.  If not, see <http://www.gnu.org/licenses/>.

set -ex
. ./sha256.sh
echo "Beginning sha256sum tests"
mkdir -p bin/tests
env printf "abc" >bin/tests/abc
env printf "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" >bin/tests/abcd
perl -e 'print "a"x1000000' >bin/tests/long
echo 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad  bin/tests/abc' >bin/tests/checks
echo '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1  bin/tests/abcd' >>bin/tests/checks
echo 'cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0  bin/tests/long' >>bin/tests/checks
bin/sha256sum -c bin/tests/checks
echo "sha256sum tests done"

echo "Beginning sha3sum tests"
mkdir -p bin/tests
env printf "">bin/tests/empty
bin/sha3sum -a 224 --verify 6b4e03423667dbb73b6e15454f0eb1abd4597f9a1b078e3f5b5a6bc7 bin/tests/empty
env printf "\x9F\x2F\xCC\x7C\x90\xDE\x09\x0D\x6B\x87\xCD\x7E\x97\x18\xC1\xEA\x6C\xB2\x11\x18\xFC\x2D\x5D\xE9\xF9\x7E\x5D\xB6\xAC\x1E\x9C\x10" > bin/tests/1
bin/sha3sum -a 256 --verify 2f1a5f7159e34ea19cddc70ebf9b81f1a66db40615d7ead3cc1f1b954d82a3af bin/tests/1
env printf "\xE3\x57\x80\xEB\x97\x99\xAD\x4C\x77\x53\x5D\x4D\xDB\x68\x3C\xF3\x3E\xF3\x67\x71\x53\x27\xCF\x4C\x4A\x58\xED\x9C\xBD\xCD\xD4\x86\xF6\x69\xF8\x01\x89\xD5\x49\xA9\x36\x4F\xA8\x2A\x51\xA5\x26\x54\xEC\x72\x1B\xB3\xAA\xB9\x5D\xCE\xB4\xA8\x6A\x6A\xFA\x93\x82\x6D\xB9\x23\x51\x7E\x92\x8F\x33\xE3\xFB\xA8\x50\xD4\x56\x60\xEF\x83\xB9\x87\x6A\xCC\xAF\xA2\xA9\x98\x7A\x25\x4B\x13\x7C\x6E\x14\x0A\x21\x69\x1E\x10\x69\x41\x38\x48" >bin/tests/2
bin/sha3sum -a 384 --verify d1c0fa85c8d183beff99ad9d752b263e286b477f79f0710b010317017397813344b99daf3bb7b1bc5e8d722bac85943a bin/tests/2
env printf "\x3A\x3A\x81\x9C\x48\xEF\xDE\x2A\xD9\x14\xFB\xF0\x0E\x18\xAB\x6B\xC4\xF1\x45\x13\xAB\x27\xD0\xC1\x78\xA1\x88\xB6\x14\x31\xE7\xF5\x62\x3C\xB6\x6B\x23\x34\x67\x75\xD3\x86\xB5\x0E\x98\x2C\x49\x3A\xDB\xBF\xC5\x4B\x9A\x3C\xD3\x83\x38\x23\x36\xA1\xA0\xB2\x15\x0A\x15\x35\x8F\x33\x6D\x03\xAE\x18\xF6\x66\xC7\x57\x3D\x55\xC4\xFD\x18\x1C\x29\xE6\xCC\xFD\xE6\x3E\xA3\x5F\x0A\xDF\x58\x85\xCF\xC0\xA3\xD8\x4A\x2B\x2E\x4D\xD2\x44\x96\xDB\x78\x9E\x66\x31\x70\xCE\xF7\x47\x98\xAA\x1B\xBC\xD4\x57\x4E\xA0\xBB\xA4\x04\x89\xD7\x64\xB2\xF8\x3A\xAD\xC6\x6B\x14\x8B\x4A\x0C\xD9\x52\x46\xC1\x27\xD5\x87\x1C\x4F\x11\x41\x86\x90\xA5\xDD\xF0\x12\x46\xA0\xC8\x0A\x43\xC7\x00\x88\xB6\x18\x36\x39\xDC\xFD\xA4\x12\x5B\xD1\x13\xA8\xF4\x9E\xE2\x3E\xD3\x06\xFA\xAC\x57\x6C\x3F\xB0\xC1\xE2\x56\x67\x1D\x81\x7F\xC2\x53\x4A\x52\xF5\xB4\x39\xF7\x2E\x42\x4D\xE3\x76\xF4\xC5\x65\xCC\xA8\x23\x07\xDD\x9E\xF7\x6D\xA5\xB7\xC4\xEB\x7E\x08\x51\x72\xE3\x28\x80\x7C\x02\xD0\x11\xFF\xBF\x33\x78\x53\x78\xD7\x9D\xC2\x66\xF6\xA5\xBE\x6B\xB0\xE4\xA9\x2E\xCE\xEB\xAE\xB1" >bin/tests/3
bin/sha3sum -a 512 --verify 6e8b8bd195bdd560689af2348bdc74ab7cd05ed8b9a57711e9be71e9726fda4591fee12205edacaf82ffbbaf16dff9e702a708862080166c2ff6ba379bc7ffc2 bin/tests/3
echo "sha3sum tests done"

echo 'Beginning tar tests'
mkdir -p bin/tests
mkdir -p bin/tests/dir1
rm -f bin/tests/check.tar bin/tests/null bin/tests/dir1/null1
ln -s /dev/null bin/tests/null
ln -s /dev/null bin/tests/dir1/null1
tar --no-recursion -cf bin/tests/check.tar bin/tests/abc bin/tests/abcd bin/tests/long bin/tests/null bin/tests/dir1 bin/tests/dir1/null1
(
	rm -rf bin/tests/tar-check
	mkdir bin/tests/tar-check
	cd bin/tests/tar-check

	../../untar --file ../check.tar

	../../sha256sum -c ../checks
	ls -l bin/tests/null bin/tests/dir1/null1
)
echo 'tar tests done'
