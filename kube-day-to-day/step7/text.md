# Identify pod by labels

## Prerequites

`kubectl run shop-1 -n saturn --image=http:2.4 --labels app=my-shop,version=2.4`{{exec}}

`kubectl run shop-2 -n saturn --image=http:2.4 --labels app=my-shop1,version=2.4`{{exec}}

`kubectl annotate pods shop-1 component=my-happy-shop --overwrite`{{exec}}

## Scenario

The board of Team Neptune decided to take over control of one e-commerce webserver from Team Saturn. The administrator who once setup this webserver is not part of the organisation any longer. All information you could get was that the e-commerce system is called `my-happy-shop`.

Search for the correct Pod in Namespace `saturn` and move it to Namespace `neptune`. It doesn't matter if you shut it down and spin it up again, it probably hasn't any customers anyways.