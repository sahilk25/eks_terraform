from operator import imod
from diagrams import Cluster, Diagram
from diagrams.aws.compute import EC2, EKS
from diagrams.aws.storage import EFS
from diagrams.k8s.network import Ingress
from diagrams.aws.database import ElastiCache, RDS
from diagrams.aws.network import ELB
from diagrams.aws.network import Route53

with Diagram("Clustered Web Services", show=False):
    dns = Route53("dns")
    lb = ELB("lb")

    with Cluster("Private Subnet"):
        with Cluster("Jenkins EKS"):
            svc_group = [EC2("Node1"),
                        EC2("Node2"),
                        EC2("Node3")]

    # with Cluster("DB Cluster"):
    #     db_primary = RDS("userdb")
    #     db_primary - [RDS("userdb ro")]

    EFS_STORAGE = EFS("Jenkins_home")
    nginx_ingtress = Ingress("nginx_ingress")
    dns >> lb >> nginx_ingtress >> svc_group
    svc_group >> EFS_STORAGE