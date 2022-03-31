___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Extract URL Component",
  "categories": ["UTILITY"],
  "description": "Parse a URL and extract one of its components with flexible formatting options",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "urlSource",
    "displayName": "URL Source",
    "macrosInSelect": true,
    "selectItems": [
      {
        "value": "event_page_location",
        "displayValue": "page_location"
      }
    ],
    "simpleValueType": true,
    "help": "Choose \u003cstrong\u003epage_location\u003c/strong\u003e to use the respective key from the Event Data object, or provide a variable that returns a valid URL string.",
    "defaultValue": "event_page_location"
  },
  {
    "type": "SELECT",
    "name": "componentType",
    "displayName": "Component Type",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "fullUrl",
        "displayValue": "Full URL"
      },
      {
        "value": "filenameExtension",
        "displayValue": "Filename Extension"
      },
      {
        "value": "fragment",
        "displayValue": "Fragment"
      },
      {
        "value": "hostName",
        "displayValue": "Host Name"
      },
      {
        "value": "path",
        "displayValue": "Path"
      },
      {
        "value": "port",
        "displayValue": "Port"
      },
      {
        "value": "scheme",
        "displayValue": "Scheme/Protocol"
      },
      {
        "value": "query",
        "displayValue": "Query Parameters"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "fullUrl"
  },
  {
    "type": "TEXT",
    "name": "queryKey",
    "displayName": "Query Key",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "componentType",
        "paramValue": "query",
        "type": "EQUALS"
      }
    ],
    "help": "If provided, returns the value of the first matching query key"
  },
  {
    "type": "CHECKBOX",
    "name": "stripWww",
    "checkboxText": "Strip \u0027www\u0027 from hostname",
    "simpleValueType": true,
    "help": "If enabled, the leading \u0027www.\u0027 will be stripped from the hostname.",
    "enablingConditions": [
      {
        "paramName": "componentType",
        "paramValue": "hostName",
        "type": "EQUALS"
      }
    ],
    "defaultValue": false
  },
  {
    "type": "CHECKBOX",
    "name": "stripHash",
    "checkboxText": "Strip \u0027#\u0027 from fragment",
    "simpleValueType": true,
    "help": "If enabled, the leading \u0027#\u0027 will be stripped from the URL fragment",
    "enablingConditions": [
      {
        "paramName": "componentType",
        "paramValue": "fragment",
        "type": "EQUALS"
      }
    ],
    "defaultValue": false
  },
  {
    "type": "CHECKBOX",
    "name": "stripQuestionMark",
    "checkboxText": "Strip \u0027?\u0027 from query string",
    "simpleValueType": true,
    "help": "If enabled, the leading \u0027?\u0027 will be stripped from the URL query",
    "enablingConditions": [
      {
        "paramName": "componentType",
        "paramValue": "query",
        "type": "EQUALS"
      }
    ],
    "defaultValue": false
  },
  {
    "type": "CHECKBOX",
    "name": "useUndefined",
    "checkboxText": "Value is \u0027undefined\u0027 if not found instead of empty string",
    "simpleValueType": true,
    "defaultValue": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

const decodeUri = require('decodeUri');
const decodeUriComponent = require('decodeUriComponent');
const getEventData = require('getEventData');
const parseUrl = require('parseUrl');
const getType = require("getType");

const fallback = (data.useUndefined) ? undefined : "";

const parsedUrl = parseUrl(data.urlSource === 'event_page_location' ? 
                           getEventData('page_location') : data.urlSource);

if (!parsedUrl) return fallback;

switch (data.componentType) {
  case 'filenameExtension':
    let ext = parsedUrl.pathname.split('.').pop();
    return (ext.lastIndexOf('/') == -1) ? ext : fallback;
  case 'fragment':
    return data.stripHash ? parsedUrl.hash.replace('#', '') : parsedUrl.hash;
  case 'fullUrl':
    return parsedUrl.href;
  case 'hostName':
    return (data.stripWww && (parsedUrl.hostname.indexOf('www.') == 0)) ?
      parsedUrl.hostname.replace('www.', '') : parsedUrl.hostname;
  case 'path':
    return parsedUrl.pathname;
  case 'port':
    return parsedUrl.port;
  case 'scheme':
    return parsedUrl.protocol;
  case 'query':
    if (data.queryKey) {
      if (parsedUrl.searchParams[data.queryKey]){
        let q = parsedUrl.searchParams[data.queryKey];
        q = (getType(q) === "array") ? q[0] : q;
        return decodeUriComponent(q);
      } else {
        return fallback;
      }
    } else {
      return data.stripQuestionMark ? parsedUrl.search.replace('?', '') : parsedUrl.search;
    }
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Test fallback handling
  code: |-
    const mockData = {
      useUndefined: true
    };

    assertThat(runCode(mockData)).isEqualTo(undefined);

    mockData.useUndefined = false;
    assertThat(runCode(mockData)).isEqualTo("");
- name: Test URL Source
  code: |+
    let url = "https://www.example.com/";
    const mockData = {
      urlSource: 'event_page_location',
      componentType: 'fullUrl'
    };
    mock("getEventData", url);
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(url);

    mockData.urlSource = "https://www.example.com/2";
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(mockData.urlSource);

- name: Test Host Name
  code: |
    let url = "https://abc:xyz@www.example.com:8080/foo?param1=val1&param2=val2%2Cue#bar";
    const mockData = {
      urlSource: url,
      componentType: 'hostName'
    };

    assertThat(runCode(mockData)).isEqualTo("www.example.com");

    mockData.urlSource = "https://WwW.Example.Com";
    assertThat(runCode(mockData)).isEqualTo("www.example.com");

    mockData.stripWww = true;
    assertThat(runCode(mockData)).isEqualTo("example.com");

    mockData.urlSource = "https://www.example.com";
    assertThat(runCode(mockData)).isEqualTo("example.com");

    mockData.urlSource = "https://subdomain.www.example.com";
    assertThat(runCode(mockData)).isEqualTo("subdomain.www.example.com");
- name: Test Fragment
  code: |
    let url = "https://abc:xyz@www.example.com:8080/foo?param1=val1&param2=val2%2Cue#bar";
    const mockData = {
      urlSource: url,
      componentType: 'fragment'
    };

    assertThat(runCode(mockData)).isEqualTo("#bar");

    mockData.stripHash = true;
    assertThat(runCode(mockData)).isEqualTo("bar");
- name: Test Path
  code: |
    let url = "https://abc:xyz@www.example.com:8080/foo?param1=val1&param2=val2%2Cue#bar";
    const mockData = {
      urlSource: url,
      componentType: 'path'
    };

    assertThat(runCode(mockData)).isEqualTo("/foo");

    mockData.urlSource = "https://abc:xyz@www.example.com:8080?param1=val1&param2=val2%2Cue#bar";
    assertThat(runCode(mockData)).isEqualTo("/");
- name: Test Scheme/Protocol
  code: |+
    let url = "https://abc:xyz@www.example.com:8080/foo?param1=val1&param2=val2%2Cue#bar";
    const mockData = {
      urlSource: url,
      componentType: 'scheme'
    };

    assertThat(runCode(mockData)).isEqualTo("https:");

- name: Test Port
  code: |
    let url = "https://abc:xyz@www.example.com:8080/foo?param1=val1&param2=val2%2Cue#bar";
    const mockData = {
      urlSource: url,
      componentType: 'port'
    };

    assertThat(runCode(mockData)).isEqualTo("8080");
- name: Test Query
  code: |-
    let url = "https://abc:xyz@www.example.com:8080/foo?param1=val1&param1=val2&param2=val3%2Cue#bar";
    const mockData = {
      urlSource: url,
      useUndefined: true,
      componentType: 'query'
    };

    assertThat(runCode(mockData)).isEqualTo("?param1=val1&param1=val2&param2=val3%2Cue");

    mockData.stripQuestionMark = true;
    assertThat(runCode(mockData)).isEqualTo("param1=val1&param1=val2&param2=val3%2Cue");

    mockData.queryKey = "";
    assertThat(runCode(mockData)).isEqualTo("param1=val1&param1=val2&param2=val3%2Cue");

    mockData.queryKey = "param1";
    assertThat(runCode(mockData)).isEqualTo("val1");

    mockData.queryKey = "param2";
    assertThat(runCode(mockData)).isEqualTo("val3,ue");

    mockData.queryKey = "xxx";
    assertThat(runCode(mockData)).isEqualTo(undefined);

    mockData.useUndefined = false;
    assertThat(runCode(mockData)).isEqualTo("");
- name: Test Filename Extension
  code: |+
    const mockData = {
      urlSource: "https://www.example.com/foo.bar/baz.pdf?p=v.1",
      useUndefined: true,
      componentType: 'filenameExtension'
    };

    assertThat(runCode(mockData)).isEqualTo("pdf");

    mockData.urlSource = "https://www.example.com/foo.bar/bazpdf?p=v.1";
    assertThat(runCode(mockData)).isEqualTo(undefined);

    mockData.urlSource = "https://www.example.com/";
    assertThat(runCode(mockData)).isEqualTo(undefined);


___NOTES___

Created on 31/03/2022, 15:27:06


