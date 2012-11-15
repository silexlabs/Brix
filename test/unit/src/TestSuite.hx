import massive.munit.TestSuite;

import brix.test.unit.component.internationalization.adapter.IniAdapterTest;
import brix.test.unit.component.internationalization.adapter.XliffAdapterTest;
import brix.test.unit.component.internationalization.TranslatorTest;
import brix.test.unit.util.data.IniTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(brix.test.unit.component.internationalization.adapter.IniAdapterTest);
		add(brix.test.unit.component.internationalization.adapter.XliffAdapterTest);
		add(brix.test.unit.component.internationalization.TranslatorTest);
		add(brix.test.unit.util.data.IniTest);
	}
}
