<?php
class P {
	#[\Deprecated]
	public const TEST4 = 4;
}
class C extends P {}
var_dump(C::TEST4);
