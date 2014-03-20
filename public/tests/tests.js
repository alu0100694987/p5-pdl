var assert = chai.assert;

suite('Resultados de los tests: ', function() {
   test('Prueba 1', function() {
        original.value = "if name == Sawan then personality = PIMP";
        main();
		assert.equal(OUTPUT.innerHTML, '{\n  "type": "IF",\n  "left": {\n    "type": "==",\n    "left": {\n      "type": "ID",\n      "value": "name"\n    },\n    "right": {\n      "type": "ID",\n      "value": "Sawan"\n    }\n  },\n  "right": {\n    "type": "=",\n    "left": {\n      "type": "ID",\n      "value": "personality"\n    },\n    "right": {\n      "type": "ID",\n      "value": "PIMP"\n    }\n  }\n}');
    });
    test('Prueba de un statement', function() {
        original.value = "while 52 > 4 do call funcion";
        main();
		assert.equal(OUTPUT.innerHTML, '{\n  "type": "WHILE",\n  "left": {\n    "type": "&gt;",\n    "left": {\n      "type": "NUM",\n      "value": 52\n    },\n    "right": {\n      "type": "NUM",\n      "value": 4\n    }\n  },\n  "right": {\n    "type": "call",\n    "rigth": {\n      "type": "ID",\n      "value": "funcion"\n    }\n  }\n}');
    });
   test('Prueba de error', function() {
        original.value = "x = 23 + (2; z = 12";
        main();
		assert.equal(OUTPUT.innerHTML, '<div class="error">Syntax Error');
    });
    test('Prueba de ID', function() {
        original.value = "nombre = Cristo";
        main();
		assert.match(OUTPUT.innerHTML, /ID/);
    });
	 test('Prueba de NUM', function() {
        original.value = "x = 69";
        main();
		assert.match(OUTPUT.innerHTML, /NUM/);
    });
});