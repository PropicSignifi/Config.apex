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
private class CacheStoreTest {
    // To run the tests, complete the following configurations and uncomment out the @isTest

    // Set up a partition and replace the name here
    private static final String PARTITION = 'ctcproperty';

    private static CacheStore store = new CacheStore(PARTITION);

    @isTest
    private static void orgCacheTest() {
        store.OrgCache.put('name', 'value');
        System.assertEquals('value', store.OrgCache.get('name'));

        store.OrgCache.reload();
        System.assertEquals('value', store.OrgCache.get('name'));
        System.assertEquals('value', store.get('name'));

        store.OrgCache.put('name', 'new value');
        System.assertEquals('new value', store.get('name'));
    }

    @isTest
    private static void sessionCacheTest() {
        store.SessionCache.put('name', 'value');

        System.assertEquals(null, store.SessionCache.get('name'));

        store.SessionCache.reload();

        System.assertEquals(null, store.SessionCache.get('name'));

        System.assertEquals(null, store.get('name'));
    }
}
