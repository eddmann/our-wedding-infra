#!/bin/bash -x

# attach the ENI
function attach_eni {
  aws ec2 attach-network-interface \
    --region "$(/opt/aws/bin/ec2-metadata -z  | sed 's/placement: \(.*\).$/\1/')" \
    --instance-id "$(/opt/aws/bin/ec2-metadata -i | cut -d' ' -f2)" \
    --device-index 1 \
    --network-interface-id "${eni_id}"
}
until attach_eni
do
  echo "Attaching ENI...";
done

# start SNAT
systemctl enable snat
systemctl start snat
