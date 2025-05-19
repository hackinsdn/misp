#!/bin/bash
api_key='<api_key>'
misp_url='<misp_url>'
curl -k -H 'Accept: application/json' -H 'Content-type: application/json' -H 'Authorization: '$api_key'' -XGET $misp_url/returnFormat:suricata/type:ip-src||ip-dst/tags:admiralty-scale:source-reliability="a"||admiralty-scale:source-reliability="b"||admiralty-scale:source-reliability="c"||admiralty-scale:information-credibility="1"||admiralty-scale:information-credibility="2"||admiralty-scale:information-credibility="3"