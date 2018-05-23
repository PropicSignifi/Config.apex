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
 * Manages platform caches
 *
 * The highlight is that CacheStore piles small cache items into buckets and manage the cache in buckets to improve effeciency.
 * */
public class CacheStore {
    // Org cache
    public CacheProvider OrgCache = null;

    // Session cache
    public CacheProvider SessionCache = null;

    /**
     * Create a cache store using the partition
     *
     * A cache store uses the CachePartition to manage the cache
     * */
    public CacheStore(String partition) {
        this.OrgCache = new OrgCacheProvider(partition);
        this.SessionCache = new SessionCacheProvider(partition);
    }

    /**
     * Check if OrgCache or SessionCache contains the key
     *
     * Example:
     * CacheStore store = new CacheStore('ctcproperty');
     * if(store.contains('key')) { ... }
     *
     * @param key The key of value put in the cache
     * @return Boolean
     * */
    public Boolean contains(String key) {
        return this.SessionCache.contains(key) || this.OrgCache.contains(key);
    }

    /**
     * Get the value from the cache mapped by the key
     *
     * Example:
     * CacheStore store = new CacheStore('ctcproperty');
     * Object value = store.get('key');
     *
     * @param key The key of the value put in the cache
     * @return Object
     * */
    public Object get(String key) {
        if(this.SessionCache.contains(key)) {
            return this.SessionCache.get(key);
        }

        if(this.OrgCache.contains(key)) {
            return this.OrgCache.get(key);
        }

        return null;
    }

    private static String NAMESPACE = 'local';

    static {
        NAMESPACE = getNamespace();
    }

    private static String getNamespace() {
        ApexClass cs = [ SELECT NamespacePrefix FROM ApexClass WHERE Name = 'CacheStore' ];
        String prefix = cs.NamespacePrefix;

        return String.isBlank(prefix) ? 'local' : prefix;
    }

    public abstract class CacheProvider {
        @TestVisible
        private List<Map<String, Object>> cacheList = null;

        CacheProvider() {
        }

        /**
         * Check if the cache provider contains a value mapped by the key in the cache
         *
         * Example:
         * ConfigStore store = new ConfigStore('ctcproperty');
         * Boolean contains = store.OrgCache.contains('key');
         *
         * @param key The key of the value put in the cache
         * @return Boolean
         * */
        public Boolean contains(String key) {
            for(Map<String, Object> cache : this.cacheList) {
                if(cache.containsKey(key)) {
                    return true;
                }
            }

            return false;
        }

        /**
         * Get the value mapped by the key from the cache
         *
         * Example:
         * ConfigStore store = new ConfigStore('ctcproperty');
         * Object value = store.OrgCache.get('key');
         *
         * @param key The key of the value put in the cache
         * @return Object
         * */
        public Object get(String key) {
            for(Map<String, Object> cache : this.cacheList) {
                if(cache.containsKey(key)) {
                    return cache.get(key);
                }
            }

            return null;
        }

        /**
         * Put the key-value into the cache
         *
         * Example:
         * ConfigStore store = new ConfigStore('ctcproperty');
         * store.OrgCache.put('key', 'value');
         *
         * @param key The key
         * @param value The value
         * @return CacheProvider
         * */
        public CacheProvider put(String key, Object value) {
            if(!this.isAvailable()) {
                return this;
            }

            Integer cacheIndex = -1;

            for(Integer i = 0; i < this.cacheList.size(); i++) {
                Map<String, Object> cache = this.cacheList.get(i);
                if(cache.containsKey(key)) {
                    cacheIndex = i;
                    break;
                }
            }

            if(cacheIndex < 0) {
                this.putInLastCache(key, value);
            }
            else {
                this.putInCertainCache(key, value, cacheIndex);
            }

            return this;
        }

        /**
         * Reload the cache
         *
         * */
        public void reload() {
            this.cacheList = new List<Map<String, Object>>();

            if(!this.isAvailable()) {
                return;
            }

            Integer index = 0;
            while(true) {
                String key = this.getQualifiedKey(index);
                Map<String, Object> cache = (Map<String, Object>)this.doGet(key);
                if(cache == null) {
                    break;
                }

                this.cacheList.add(cache);

                index++;
            }
        }

        private String getQualifiedKey(Integer index) {
            return 'cache' + String.valueOf(index);
        }

        protected String getQualifiedPartition(String partition) {
            return NAMESPACE + '.' + partition;
        }

        abstract Cache.Partition getPartition();

        private Object doGet(String key) {
            return this.getPartition().get(key);
        }

        private void doPut(String key, Object value) {
            this.getPartition().put(key, value);
        }

        private Boolean isAvailable() {
            return this.getPartition().isAvailable();
        }

        private void putInCertainCache(String key, Object value, Integer cacheIndex) {
            String cacheKey = this.getQualifiedKey(cacheIndex);
            Map<String, Object> cache = this.cacheList.get(cacheIndex);

            try {
                cache.put(key, value);

                this.doPut(cacheKey, cache);
            }
            catch(Cache.ItemSizeLimitExceededException e) {
                cache.remove(key);
                this.doPut(cacheKey, cache);

                this.putInLastCache(key, value);
            }
        }

        private void putInLastCache(String key, Object value) {
            if(this.cacheList.isEmpty()) {
                this.putInNewCache(key, value);
                return;
            }

            Integer cacheIndex = this.cacheList.size() - 1;
            String cacheKey = this.getQualifiedKey(cacheIndex);
            Map<String, Object> cache = this.cacheList.get(cacheIndex);

            try {
                cache.put(key, value);

                this.doPut(cacheKey, cache);
            }
            catch(Cache.ItemSizeLimitExceededException e) {
                cache.remove(key);
                this.doPut(cacheKey, cache);

                this.putInNewCache(key, value);
            }
        }

        private void putInNewCache(String key, Object value) {
            Integer cacheIndex = this.cacheList.size();
            String cacheKey = this.getQualifiedKey(cacheIndex);
            Map<String, Object> cache = new Map<String, Object>();

            try {
                cache.put(key, value);

                this.doPut(cacheKey, cache);

                this.cacheList.add(cache);
            }
            catch(Cache.ItemSizeLimitExceededException e) {
                // We simply skip putting it into cache as the single item exceeds cache item size limit
            }
        }
    }

    class OrgCacheProvider extends CacheProvider {
        private Cache.Partition cachePartition = null;

        OrgCacheProvider(String partition) {
            super();

            this.cachePartition = Cache.Org.getPartition(this.getQualifiedPartition(partition));

            this.reload();
        }

        public override Cache.Partition getPartition() {
            return this.cachePartition;
        }
    }

    class SessionCacheProvider extends CacheProvider {
        private Cache.Partition cachePartition = null;

        SessionCacheProvider(String partition) {
            super();

            this.cachePartition = Cache.Session.getPartition(this.getQualifiedPartition(partition));

            this.reload();
        }

        public override Cache.Partition getPartition() {
            return this.cachePartition;
        }
    }
}
