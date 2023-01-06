/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

parser grammar KyuubiTrinoFeBaseParser;

options { tokenVocab = KyuubiSqlBaseLexer; }

singleStatement
    : statement SEMICOLON* EOF
    ;

statement
    : SELECT TABLE_SCHEM COMMA TABLE_CATALOG FROM SYSTEM_JDBC_SCHEMAS
      (WHERE (TABLE_CATALOG EQ catalog=STRING+)? AND? (TABLE_SCHEM LIKE schema=STRING+)?)?
      ORDER BY TABLE_CATALOG COMMA TABLE_SCHEM                                                      #getSchemas
    | SELECT TABLE_CAT FROM SYSTEM_JDBC_CATALOGS ORDER BY TABLE_CAT                                 #getCatalogs
    | SELECT TABLE_TYPE FROM SYSTEM_JDBC_TABLE_TYPES ORDER BY TABLE_TYPE                            #getTableTypes
    | SELECT TYPE_NAME COMMA DATA_TYPE COMMA PRECISION COMMA LITERAL_PREFIX COMMA
      LITERAL_SUFFIX COMMA CREATE_PARAMS COMMA NULLABLE COMMA CASE_SENSITIVE COMMA
      SEARCHABLE COMMA UNSIGNED_ATTRIBUTE COMMA FIXED_PREC_SCALE COMMA AUTO_INCREMENT
      COMMA LOCAL_TYPE_NAME COMMA MINIMUM_SCALE COMMA MAXIMUM_SCALE COMMA SQL_DATA_TYPE
      COMMA SQL_DATETIME_SUB COMMA NUM_PREC_RADIX FROM SYSTEM_JDBC_TYPES ORDER BY DATA_TYPE         #getTypeInfo
    | SELECT TABLE_CAT COMMA TABLE_SCHEM COMMA TABLE_NAME COMMA TABLE_TYPE COMMA REMARKS COMMA
      TYPE_CAT COMMA TYPE_SCHEM COMMA TYPE_NAME COMMA SELF_REFERENCING_COL_NAME COMMA REF_GENERATION
      FROM SYSTEM_JDBC_TABLES
      (WHERE tableCatalogFilter? AND? tableSchemaFilter? AND? tableNameFilter? AND? tableTypeFilter?)?
      ORDER BY TABLE_TYPE COMMA TABLE_CAT COMMA TABLE_SCHEM COMMA TABLE_NAME                        #getTables
    | .*?                                                                                           #passThrough
    ;

tableCatalogFilter
    : TABLE_CAT IS NULL                                                                             #nullCatalog
    | TABLE_CAT EQ catalog=STRING+                                                                  #catalogFilter
    ;

tableSchemaFilter
    : TABLE_SCHEM IS NULL                                                                           #nulTableSchema
    | TABLE_SCHEM LIKE schemaPattern=STRING+ ESCAPE SEARCH_STRING_ESCAPE                            #schemaFilter
    ;

tableNameFilter
    : TABLE_NAME LIKE tableNamePattern=STRING+ ESCAPE SEARCH_STRING_ESCAPE
    ;

tableTypeFilter
    : FALSE                                                                                         #tableTypesAlwaysFalse
    | TABLE_TYPE IN '(' stirngInValue (',' stirngInValue)* ')'                                      #typesFilter
    ;

stirngInValue
    : STRING+
    ;