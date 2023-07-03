#!/bin/bash

REDIS_VALUES_FILE=$1

GUESTBOOK_VALUES_FILE=$2


if [ -z "$REDIS_VALUES_FILE" ]; then
	REDIS_VALUES_FILE="redis/values.yaml"
fi

if [ -z "$GUESTBOOK_VALUES_FILE" ]; then
	GUESTBOOK_VALUES_FILE="guestbook/values.yaml"
fi


helm dependency build redis/

helm install redis redis/ --values $REDIS_VALUES_FILE

if [ "$?" -eq 0 ];
then
	sleep 5

	while true
	do
        	OK_FLAG=1

        	for status in $(kubectl get pods | sed '1d' | tr -s ' ' | cut -d ' ' -f 3);
        	do
                	if [ "$status" != "Running" ]
                	then
                        	OK_FLAG=0
				break
                	fi
        	done

        	if [ "$OK_FLAG" -eq 1 ]
        	then
			helm install guestbook guestbook/ --values $GUESTBOOK_VALUES_FILE
			break
        	fi
	done
fi

