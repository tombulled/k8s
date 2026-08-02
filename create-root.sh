#!/bin/bash

helm template \
	../tenant/tenant \
	-f values/root/values.yaml \
	-f values/root/values-low.yaml \
	| yq \
		'select(.kind == "Application") | select(.metadata.name == "root")'
