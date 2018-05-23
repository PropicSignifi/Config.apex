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
/**
 * The config service
 *
 * Config is backed by CacheStore, and seeks to provide a universal way to read/write config values
 *
 * Example:
 * CacheStore store = new CacheStore('ctcproperty');
 * Config configService = new Config(store);
 *
 * configService.onRead('/System/CustomButton/list', new SObjectHandler('Custom_Button__c')
 *     .fetch('SELECT Id, Name FROM Custom_Button__c')
 * );
 *
 * List<Custom_Button__c> buttons = (List<Custom_Button__c>)configService.get('/System/CustomButton/list');
 *
 * // With parameters
 * String name = (String)configService.get('/System/User/${id}/Name');
 *
 * */
public class Config {
    /**
     * The Org level scope
     * */
    public static final String SCOPE_ORG = 'Org';

    /**
     * The Session level scope
     * */
    public static final String SCOPE_SESSION = 'Session';

    // The backed up CacheStore
    private CacheStore store = null;

    // The config handlers to handle the config requests
    private List<ConfigHandler> handlers = new List<ConfigHandler>();

    /**
     * Create a Config from CacheStore
     * */
    public Config(CacheStore store) {
        this.store = store;
    }

    /**
     * Get all registered config paths
     *
     * @return List<String>
     * */
    public List<String> getConfigPaths() {
        List<String> paths = new List<String>();

        for(ConfigHandler handler : this.handlers) {
            paths.add(handler.getPath());
        }

        return paths;
    }

    /**
     * Register a read/write handler
     *
     * Example:
     * configService.onReadWrite('/System/test', false, SCOPE_ORG, new OnReadFunc(), new OnWriteFunc());
     *
     * @param path The path
     * @param cache Whether to use cache
     * @param scope The scope
     * @param onRead The onRead Func
     * @param onWrite The onWrite Func
     * @return Config
     * */
    public Config onReadWrite(String path, Boolean cache, String scope, Func onRead, Func onWrite) {
        ConfigHandler handler = this.findHandler(path);

        if(handler == null) {
            this.handlers.add(new ConfigHandler(String.valueOf(this.handlers.size()), path, this.store, cache, scope, onRead, onWrite));
        }
        else {
            handler.setCache(cache);
            handler.setScope(scope);
            handler.setOnRead(onRead);
            handler.setOnWrite(onWrite);
        }

        return this;
    }

    /**
     * Register a read/write handler
     *
     * Example:
     * configService.onReadWrite('/System/test', false, new OnReadFunc(), new OnWriteFunc());
     *
     * @param path The path
     * @param cache Whether to use cache
     * @param onRead The onRead Func
     * @param onWrite The onWrite Func
     * @return Config
     * */
    public Config onReadWrite(String path, Boolean cache, Func onRead, Func onWrite) {
        return this.onReadWrite(path, cache, SCOPE_ORG, onRead, onWrite);
    }

    /**
     * Register a read/write handler
     *
     * Example:
     * configService.onReadWrite('/System/test', new OnReadFunc(), new OnWriteFunc());
     *
     * @param path The path
     * @param onRead The onRead Func
     * @param onWrite The onWrite Func
     * @return Config
     * */
    public Config onReadWrite(String path, Func onRead, Func onWrite) {
        return this.onReadWrite(path, true, onRead, onWrite);
    }

    /**
     * Register a read handler
     *
     * Example:
     * configService.onRead('/System/test', false, SCOPE_ORG, new OnReadFunc());
     *
     * @param path The path
     * @param cache Whether to use cache
     * @param scope The scope
     * @param onRead The onRead Func
     * @return Config
     * */
    public Config onRead(String path, Boolean cache, String scope, Func onRead) {
        return this.onReadWrite(path, cache, scope, onRead, null);
    }

    /**
     * Register a read handler
     *
     * Example:
     * configService.onRead('/System/test', false, new OnReadFunc());
     *
     * @param path The path
     * @param cache Whether to use cache
     * @param onRead The onRead Func
     * @return Config
     * */
    public Config onRead(String path, Boolean cache, Func onRead) {
        return this.onRead(path, cache, SCOPE_ORG, onRead);
    }

    /**
     * Register a read handler
     *
     * Example:
     * configService.onRead('/System/test', new OnReadFunc());
     *
     * @param path The path
     * @param onRead The onRead Func
     * @return Config
     * */
    public Config onRead(String path, Func onRead) {
        return this.onRead(path, true, onRead);
    }

    /**
     * Register a write handler
     *
     * Example:
     * configService.onWrite('/System/test', false, SCOPE_ORG, new OnWriteFunc());
     *
     * @param path The path
     * @param cache Whether to use cache
     * @param scope The scope
     * @param onWrite The onWrite Func
     * @return Config
     * */
    public Config onWrite(String path, Boolean cache, String scope, Func onWrite) {
        return this.onReadWrite(path, cache, scope, null, onWrite);
    }

    /**
     * Register a write handler
     *
     * Example:
     * configService.onWrite('/System/test', false, new OnWriteFunc());
     *
     * @param path The path
     * @param cache Whether to use cache
     * @param onWrite The onWrite Func
     * @return Config
     * */
    public Config onWrite(String path, Boolean cache, Func onWrite) {
        return this.onWrite(path, cache, SCOPE_ORG, onWrite);
    }

    /**
     * Register a write handler
     *
     * Example:
     * configService.onWrite('/System/test', new OnWriteFunc());
     *
     * @param path The path
     * @param onWrite The onWrite Func
     * @return Config
     * */
    public Config onWrite(String path, Func onWrite) {
        return this.onWrite(path, true, onWrite);
    }

    /**
     * Get the value from the config path
     *
     * Example:
     * String version = (String)configService.get('/System/version');
     *
     * @param path The config path
     * @return Object
     * */
    public Object get(String path) {
        return this.read(path);
    }

    /**
     * Get the value from the config path
     *
     * Example:
     * String version = (String)configService.read('/System/version');
     *
     * @param path The config path
     * @return Object
     * */
    public Object read(String path) {
        for(ConfigHandler handler : this.handlers) {
            Map<String, String> params = handler.matches(path);

            if(params != null) {
                return handler.read(params);
            }
        }

        return null;
    }

    /**
     * Write the value to the config path
     *
     * Example:
     * configService.put('/System/version', new Map<String, Object>{
     *     'value': '1.0.0'
     * });
     *
     * @param path The config path
     * @param data The config data
     * @return Config
     * */
    public Config put(String path, Map<String, Object> data) {
        return this.write(path, data);
    }

    /**
     * Write the value to the config path
     *
     * Example:
     * configService.write('/System/version', new Map<String, Object>{
     *     'value': '1.0.0'
     * });
     *
     * @param path The config path
     * @param data The config data
     * @return Config
     * */
    public Config write(String path, Map<String, Object> data) {
        if(data == null) {
            data = new Map<String, Object>();
        }

        for(ConfigHandler handler : this.handlers) {
            Map<String, String> params = handler.matches(path);

            if(params != null) {
                handler.write(params, data);
            }
        }

        return this;
    }

    private ConfigHandler findHandler(String path) {
        for(ConfigHandler handler : this.handlers) {
            if(handler.getPath() == path) {
                return handler;
            }
        }

        return null;
    }

    private static final String PATTERN_REGEX = '\\$\\{([^/]+)\\}';
    private static final Pattern PATTERN_PATTERN = Pattern.compile(PATTERN_REGEX);

    private static final Func dbUpdate = new DbUpdateFunc();


    // Match the input against the pattern like this:
    // input => '/System/a/b'
    // pattern => '/System/${arg1}/${arg2}'
    // return the map { arg1 => a, arg2 => b }
    private static Map<String, String> matches(String input, String ptn) {
        if(input == null || ptn == null) {
            return null;
        }

        Map<String, String> variables = new Map<String, String>();

        Integer pos = input.lastIndexOf('?');
        if(pos > 0) {
            String params = input.substring(pos + 1);
            input = input.substring(0, pos);
            input = EncodingUtil.urlDecode(input, 'UTF-8');

            List<String> paramList = params.split('&');
            for(String param : paramList) {
                List<String> items = param.split('=');
                String paramName = items.get(0);
                String paramValue = null;
                if(items.size() >= 2) {
                    paramValue = items.get(1);
                }

                variables.put(paramName, paramValue);
            }
        }

        List<String> names = new List<String>();

        Pattern p = PATTERN_PATTERN;
        Matcher m = p.matcher(ptn);
        while(m.find()) {
            names.add(m.group(1));

            if(m.hitEnd()) {
                break;
            }
        }

        List<String> values = new List<String>();

        String regex = ptn.replaceAll('\\$\\{[^/]+\\}', '([^/]+)');
        p = Pattern.compile(regex);
        m = p.matcher(input);

        if(m.matches()) {
            for(Integer i = 1; i <= m.groupCount(); i++) {
                values.add(m.group(i));
            }
        }
        else {
            return null;
        }

        for(Integer i = 0; i < names.size(); i++) {
            String name = names.get(i);
            String value = null;
            if(i < values.size()) {
                value = values.get(i);
            }

            variables.put(name, value);
        }

        return variables;
    }

    class ConfigHandler {
        private String id;
        private String path;
        private CacheStore store;
        private Boolean cache;
        private String scope;
        private Func onRead;
        private Func onWrite;

        public ConfigHandler(String id, String path, CacheStore store, Boolean cache, String scope, Func onRead, Func onWrite) {
            this.id = id;
            this.path = path;
            this.store = store;

            this.setCache(cache);
            this.setScope(scope);
            this.setOnRead(onRead);
            this.setOnWrite(onWrite);
        }

        public ConfigHandler setCache(Boolean cache) {
            this.cache = cache;

            return this;
        }

        public ConfigHandler setScope(String scope) {
            this.scope = scope;

            return this;
        }

        public ConfigHandler setOnRead(Func onRead) {
            this.onRead = onRead;

            return this;
        }

        public ConfigHandler setOnWrite(Func onWrite) {
            this.onWrite = onWrite;

            return this;
        }

        public String getPath() {
            return this.path;
        }

        public Map<String, String> matches(String path) {
            return Config.matches(path, this.path);
        }

        public Object read(Map<String, String> params) {
            CacheStore.CacheProvider provider = this.getCacheProvider();

            if(provider != null) {
                String cacheKey = this.getCacheKey(params);
                Object value = provider.get(cacheKey);

                if(value == null) {
                    value = this.doRead(params);
                    provider.put(cacheKey, value);
                }

                return value;
            }
            else {
                return this.doRead(params);
            }
        }

        public void write(Map<String, String> params, Map<String, Object> data) {
            if(this.onWrite != null) {
                this.onWrite.run(params, data);

                CacheStore.CacheProvider provider = this.getCacheProvider();
                if(provider != null) {
                    provider.reload();
                }
            }
        }

        private Object doRead(Map<String, String> params) {
            if(this.onRead != null) {
                Object value = this.onRead.run(params);
                return toType(value, params.get('type'));
            }
            else {
                return null;
            }
        }

        private Object toType(Object value, String type) {
            if(type == 'Boolean') {
                return R.toBoolean.run(value);
            }
            else if(type == 'Integer') {
                return R.toInteger.run(value);
            }
            else if(type == 'Long') {
                return R.toLong.run(value);
            }
            else if(type == 'Double') {
                return R.toDouble.run(value);
            }
            else if(type == 'Decimal') {
                return R.toDecimal.run(value);
            }
            else if(type == 'String') {
                return R.toString.run(value);
            }
            else if(type == 'List') {
                return R.toList.run(value);
            }
            else if(type == 'Set') {
                return R.toSet.run(value);
            }
            else if(type == 'Map') {
                return R.toMap.run(value);
            }
            else if(type == 'SObject') {
                return R.toSObject.run(value);
            }
            else if(type == 'Date') {
                return R.toDate.run(value);
            }
            else if(type == 'Time') {
                return R.toTime.run(value);
            }
            else if(type == 'Datetime') {
                return R.toDatetime.run(value);
            }
            else if(type == 'Func') {
                return R.toFunc.run(value);
            }
            else {
                return value;
            }
        }

        private CacheStore.CacheProvider getCacheProvider() {
            if(this.store != null && this.cache) {
                if(SCOPE_ORG == this.scope) {
                    return this.store.OrgCache;
                }
                else {
                    return this.store.SessionCache;
                }
            }

            return null;
        }

        private String getCacheKey(Map<String, String> params) {
            List<String> items = new List<String>();

            for(String key : params.keySet()) {
                String value = params.get(key);
                items.add(key);
                items.add(value);
            }

            return this.id + '_' + String.join(items, '_');
        }
    }

    private class DbUpdateFunc extends Func {
        public DbUpdateFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Map<String, Object> data = (Map<String, Object>)R.toMap.run(arg1);

            List<SObject> sObjList = new List<SObject>();
            if(arg2 instanceof SObject) {
                sObjList.add((SObject)arg2);
            }
            else if(arg2 instanceof List<SObject>) {
                sObjList = (List<SObject>)arg2;
            }

            for(SObject sObj : sObjList) {
                for(String key : data.keySet()) {
                    Object value = data.get(key);
                    sObj.put(key, value);
                }
            }

            return R.dbUpdate.run(sObjList);
        }
    }

    /**
     * Convenience handler to manage SObjects/CustomSettings
     * */
    public class SObjectHandler extends Func {
        // The name of the sObject
        private String name;

        // List of Funcs to process the data
        private List<Func> funcs = new List<Func>();

        // Type of sObject
        private Type objectType;

        /**
         * Construct a handler for the SObject
         *
         * @param name The sObject name
         * */
        public SObjectHandler(String name) {
            super(-1);

            this.name = name;
            this.objectType = Type.forName(name);
        }

        private SObjectHandler addFunc(Func f) {
            this.funcs.add(f);

            return this;
        }

        /**
         * Fetch all records using the query
         *
         * Example:
         * new SObjectHandler('Custom_Button__c').fetch('SELECT Id FROM Custom_Button__c');
         *
         * @param query The SOQL query
         * @return SObjectHandler
         * */
        public SObjectHandler fetch(String query) {
            return this.addFunc(R.dbQuery.apply(query));
        }

        /**
         * Append a Func to process the data
         *
         * Example:
         * new SObjectHandler('Custom_Button__c')
         *     .fetch('SELECT Id FROM Custom_Button__c')
         *     .then(R.pluck.apply('URL__c'));
         *
         * @param f The Func
         * @return SObjectHandler
         * */
        public SObjectHandler then(Func f) {
            return this.addFunc(f);
        }

        /**
         * Insert the data as the SObject/CustomSetting
         *
         * Example:
         * new SObjectHandler('Custom_Button__c')
         *     .doInsert(new Map<String, Object>{ ... });
         *
         * @param data The data of the new SObject
         * @return SObjectHandler
         * */
        public SObjectHandler doInsert(Map<String, Object> data) {
            if(data == null) {
                data = new Map<String, Object>();
            }

            SObject sObj = (SObject)this.objectType.newInstance();
            for(String key : data.keySet()) {
                Object value = data.get(key);
                sObj.put(key, value);
            }

            return this.addFunc(R.dbInsert.apply(sObj));
        }

        /**
         * Update the input sobjects with the given data
         *
         * Example:
         * new SObjectHandler('Custom_Button__c')
         *     .fetch('SELECT Id, Name FROM Custom_Button__c')
         *     .doUpdate(new Map<String, Object>{ ... });
         *
         * @param data The data to update the sobject list
         * @return SObjectHandler
         * */
        public SObjectHandler doUpdate(Map<String, Object> data) {
            if(data == null) {
                data = new Map<String, Object>();
            }

            return this.addFunc(Config.dbUpdate.apply(data));
        }

        /**
         * Delete the input sobjects
         *
         * Example:
         * new SObjectHandler('Custom_Button__c')
         *     .fetch('SELECT Id FROM Custom_Button__c')
         *     .doDelete();
         *
         * @return SObjectHandler
         * */
        public SObjectHandler doDelete() {
            return this.addFunc(R.dbDelete);
        }

        public override Object exec(Object arg1) {
            Func pipe = (Func)R.pipe.runN(this.funcs);
            return pipe.run(arg1);
        }

        public override Object exec(Object arg1, Object arg2) {
            Func pipe = (Func)R.pipe.runN(this.funcs);
            return pipe.run(arg1, arg2);
        }
    }
}
