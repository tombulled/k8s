#!/bin/bash

helm template \
	../tenant/tenant \
	-f values/root/values.yaml \
	-f values/root/values-low.yaml \
	| yq \
		'select(.metadata.name == "root")'
