#ifndef GAMEALGORITHM_BI
#define GAMEALGORITHM_BI

#include once "windows.bi"

' Тип ячейки в лабиринте
Enum SquareLType
	' Свободная непомеченная ячейка
	Blank = -2
	' Непроходимая ячейка, стена
	Wall = -1
	' Стартовая ячейка
	Start = 0
End Enum

Type LeePathLength As Integer

/'
	волновой алгоритм Ли нахождения пути в лабиринте
	
	ptStart — точка отправления.
	ptEnd — точка назначения.
	StageHeight — высота лабиринта (количество клеток по вертикали)
	StageWidth — ширина лабиринта (количество клеток по горизонтали)
	Grid — указатель на массив специальным образом сформированного лабиринта
	IncludeDiagonalPath — флаг, определающий включение диагональных путей
	pPath — указатель на массив (одномерный) координат пути
	Массив pPath должен иметь достаточную длину, чтобы вместить весь путь (StageHeight * StageWidth)
	Сюда функция запишет координаты пути, если он существует
	
	Возвращает длину пути, 0 если пути не существует
	
	Замечания
	Координаты в лабиринте начинаются с нуля
	Координаты в лабиринте хранятся строками по ширине. [y * StageWidth + x]
	Лабиринт необходимо соответствующим образом подготовить
	Для этого все свободные клетки должны иметь значение SquareLType.Blank
	Все непроходимые клетки (стены) должны иметь значение SquareLType.Wall
	Стартовая клетка должна быть помечена SquareLType.Start
	Необходимо помнить, что значения ячеек лабиринта Greed в процессе работы функции
	будут изменены (желательно отправлять копию оригинального лабиринта)
	
'/

Declare Function GetLeePath( _
	ByVal ptStart As POINT, _
	ByVal ptEnd As POINT, _
	ByVal StageWidth As Integer, _
	ByVal StageHeight As Integer, _
	ByVal Grid As Integer Ptr, _
	ByVal IncludeDiagonalPath As Boolean, _
	ByVal pPath As POINT Ptr _
)As LeePathLength

#endif
