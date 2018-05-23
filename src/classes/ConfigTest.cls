/**
 * MIT License
 *
 * Copyright (c) 2018 Click to Cloud Pty Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 **/
@isTest
private class ConfigTest {
    // To run the tests, complete the following configurations and uncomment out the @isTest

    // Set up a partition and replace the name here
    private static final String PARTITION = 'ctcproperty';

    // Set up the custom setting
    private static final String CUSTOM_SETTING = 'Custom_Button__c';

    // Set up the custom setting data
    private static final Map<String, Object> CUSTOM_SETTING_DATA = new Map<String, Object>{
        'Name' => 'new custom button',
        'Button_Label__c' => 'Label',
        'UI_Card__c' => 'Card',
        'URL__c' => 'URL'
    };

    private static CacheStore store = new CacheStore(PARTITION);
    private static Config c = new Config(store);

    @isTest
    private static void readTest() {
        c.onRead('/System/version', R.constant.apply(1));

        System.assertEquals(1, c.read('/System/version'));

        c.onRead('/System/${name}/${value}', R.identity);

        System.assertEquals(new Map<String, String>{ 'name' => 'a', 'value' => 'b' }, c.get('/System/a/b'));
    }

    @isTest
    private static void writeTest() {
        ConfigManager cm = new ConfigManager();

        c.onReadWrite('/System/version', cm, cm);

        c.write('/System/version', new Map<String, Object>{ 'value' => 1 });
        System.assertEquals(new Map<String, Object>{ 'value' => 1 }, c.read('/System/version'));

        c.onReadWrite('/System/${name}/${value}', cm, cm);

        c.put('/System/a/b', new Map<String, Object>{ 'value' => 1 });
        System.assertEquals(new Map<String, Object>{
            'value' => 1,
            'name' => 'a',
            'value' => 'b'
        }, c.get('/System/a/b'));
    }

    @isTest
    private static void sobjectHandlerTest() {
        c.onWrite('/System/CustomButton/new', new Config.SObjectHandler(CUSTOM_SETTING)
            .doInsert(CUSTOM_SETTING_DATA)
        );
        c.onRead('/System/CustomButton/list', new Config.SObjectHandler(CUSTOM_SETTING)
            .fetch('SELECT Id FROM ' + CUSTOM_SETTING)
        );

        c.write('/System/CustomButton/new', new Map<String, Object>());
        List<SObject> result = (List<SObject>)c.read('/System/CustomButton/list');

        System.assert(!result.isEmpty());
    }

    @isTest
    private static void configTypeTest() {
        c.onRead('/System/test', new TypeFunc());

        List<String> paths = c.getConfigPaths();
        System.assert(!paths.isEmpty());

        Boolean retBoolean = (Boolean)c.get('/System/test?type=Boolean');
        System.assert(retBoolean != null);

        Integer retInteger = (Integer)c.get('/System/test?type=Integer');
        System.assert(retInteger != null);

        Long retLong = (Long)c.get('/System/test?type=Long');
        System.assert(retLong != null);

        Double retDouble = (Double)c.get('/System/test?type=Double');
        System.assert(retDouble != null);

        Decimal retDecimal = (Decimal)c.get('/System/test?type=Decimal');
        System.assert(retDecimal != null);

        String retString = (String)c.get('/System/test?type=String');
        System.assert(retString != null);

        List<Object> retList = (List<Object>)c.get('/System/test?type=List');
        System.assert(retList != null);

        Set<String> retSet = (Set<String>)c.get('/System/test?type=Set');
        System.assert(retSet != null);

        Map<String, Object> retMap = (Map<String, Object>)c.get('/System/test?type=Map');
        System.assert(retMap != null);

        SObject retSObject = (SObject)c.get('/System/test?type=SObject');
        System.assert(retSObject != null);

        Date retDate = (Date)c.get('/System/test?type=Date');
        System.assert(retDate != null);

        Time retTime = (Time)c.get('/System/test?type=Time');
        System.assert(retTime != null);

        Datetime retDatetime = (Datetime)c.get('/System/test?type=Datetime');
        System.assert(retDatetime != null);

        Func retFunc = (Func)c.get('/System/test?type=Func');
        System.assert(retFunc != null);
    }

    private class TypeFunc extends Func {
        public TypeFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, String> params = (Map<String, String>)arg;

            String type = params.get('type');
            if(type == 'Boolean') {
                return true;
            }
            else if(type == 'Integer') {
                return 0;
            }
            else if(type == 'Long') {
                return 0;
            }
            else if(type == 'Double') {
                return 0;
            }
            else if(type == 'Decimal') {
                return 0;
            }
            else if(type == 'String') {
                return 'abc';
            }
            else if(type == 'List') {
                return new List<Object>();
            }
            else if(type == 'Set') {
                return new Set<String>();
            }
            else if(type == 'Map') {
                return new Map<String, Object>();
            }
            else if(type == 'SObject') {
                return new Account();
            }
            else if(type == 'Date') {
                return Datetime.now().date();
            }
            else if(type == 'Time') {
                return Datetime.now().time();
            }
            else if(type == 'Datetime') {
                return Datetime.now();
            }
            else if(type == 'Func') {
                return R.identity;
            }
            else {
                return null;
            }
        }
    }

    private class ConfigManager extends Func {
        private Map<String, Object> data = new Map<String, Object>();

        public override Object exec(Object arg) {
            Map<String, String> params = (Map<String, String>)arg;

            Map<String, Object> mMap = new Map<String, Object>();
            mMap.putAll(this.data);
            mMap.putAll(params);

            return mMap;
        }

        public override Object exec(Object arg1, Object arg2) {
            Map<String, String> params = (Map<String, String>)arg1;
            Map<String, Object> data = (Map<String, Object>)arg2;

            this.data.putAll(params);
            this.data.putAll(data);

            return this.data;
        }
    }
}
