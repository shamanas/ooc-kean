/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

Vector2D: class <T> {
	_backend: T*
	_capacityRows: Int
	_capacityColumns: Int
	capacityRows ::= this _capacityRows
	capacityColumns ::= this _capacityColumns
	_freeContent: Bool

	init: func ~preallocated (=_backend, =_capacityRows, =_capacityColumns, freeContent := true)
	init: func (=_capacityRows, =_capacityColumns, freeContent := true) {
		this _freeContent = freeContent
		this _allocate(capacityRows, capacityColumns)
		memset(this _backend, 0, capacityRows * capacityColumns * T size)
	}

	_allocate: func (rows, columns: Int) {
		this _backend = gc_realloc(this _backend, rows * columns * T size)
	}

	free: override func {
		if (!(this instanceOf?(Vector2D)))
			gc_free(this _backend)
		super()
	}

	_elementPosition: func(row, column: Int) -> Int {
		result := capacityRows * row + column
	}

	operator [] (row, column: Int) -> T {
		version (safe) {
			if (row >= capacityRows || row < 0 || column >= capacityColumns || column < 0)
				raise("Accessing Vector2D index out of range in get operator")
		}
		this _backend[_elementPosition(row, column)]
	}

	operator []= (row, column: Int, item: T) {
		version (safe) {
			if (row >= capacityRows || row < 0 || column >= capacityColumns || column < 0)
				raise("Accessing Vector2D index out of range in set operator")
		}
		this _backend[_elementPosition(row, column)] = item
	}
}
