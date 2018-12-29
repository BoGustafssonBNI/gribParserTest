//
//  Parse.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2018-12-28.
//  Copyright © 2018 Bo Gustafsson. All rights reserved.
//

import Foundation

class Parse {
    var fileName : String?
    func open(file: String)  {
        print(file)
        let u = fopen(file, "r")
        var ierr : Int32 = 0
        let pointer : OpaquePointer? = nil
        let handle = grib_handle_new_from_file(pointer, u, &ierr)
        let number = grib_count_in_file(pointer, u, &ierr)
        print(number)
        print(grib_handle_delete(handle))
        fclose(u)
    }
    func getKeys(file: String) {
        //        let MAX_KEY_LEN = 255
        let MAX_VAL_LEN = 1024
        let key_iterator_filter_flags : Int32  = GRIB_KEYS_ITERATOR_ALL_KEYS
        
 /* Choose a namespace. E.g. "ls", "time", "parameter", "geography", "statistics" */
        let name_space="statistics"
        
        /* name_space=NULL to get all the keys */
        /* char* name_space=0; */
        
        
        var err: Int32  = 0
        var grib_count = 0
        
        var value = [CChar]()
        value.reserveCapacity(MAX_VAL_LEN)
        
        let f = fopen(file,"r")
        let p : OpaquePointer? = nil
        var h = grib_handle_new_from_file(p,f,&err)
        while (h != nil)
        {
            //                grib_keys_iterator* kiter=NULL;
            grib_count += 1
            print("-- GRIB N. \(grib_count) --\n")
            
            let kiter = grib_keys_iterator_new(h, UInt(key_iterator_filter_flags), name_space)
            if (kiter == nil) {
                print("ERROR: Unable to create keys iterator\n")
            }
            
            while(grib_keys_iterator_next(kiter) == 1)
            {
                let name = grib_keys_iterator_get_name(kiter)
                var vlen = MAX_VAL_LEN
                bzero(&value, vlen)
                grib_get_string(h,name,&value,&vlen)
                if let string = String(validatingUTF8: name!), let svalue = String(validatingUTF8: &value) {
                    print(string, svalue)
                }
            }
            grib_keys_iterator_delete(kiter)
            grib_handle_delete(h)
            h = grib_handle_new_from_file(p,f,&err)
        }
    }
}
