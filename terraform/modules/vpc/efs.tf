########################################################
#
#   Create the EFS file system and the mount targets
#   Mount targets are endpoints placed in each of the
#   k8s node subnets.
#
########################################################

resource "aws_efs_file_system" "eks_pv" {
  tags = local.tags
}

resource "aws_efs_mount_target" "pv_mount_target" {
  count = var.numAZs

  file_system_id  = aws_efs_file_system.eks_pv.id
  subnet_id       = module.vpc.private_subnet_objects[count.index].id
  security_groups = tolist([aws_security_group.efs_mount_target.id])
}

########################################################
#
#   Security group for EFS mount targets to allow
#   nodes to access the EFS (NFS) port
#
########################################################

resource "aws_security_group" "efs_mount_target" {
  name        = "efs_mount_target"
  description = "Allow EFS access from nodes"
  vpc_id      = module.vpc.vpc_id

  tags = local.tags
}

resource "aws_security_group_rule" "efs_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.efs_mount_target.id
  cidr_blocks       = tolist([var.vpc_cidr])
  protocol          = "tcp"
  from_port         = 2049
  to_port           = 2049
}

resource "aws_security_group_rule" "efs_egress" {
  type              = "egress"
  security_group_id = aws_security_group.efs_mount_target.id
  cidr_blocks       = tolist([var.vpc_cidr])
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
}


########################################################
#
#   k8s storage class to allow for dynamic provisioning
#   of PersistentVolumeClaims
#
########################################################

resource "kubernetes_storage_class" "efs-sc" {
  metadata {
    name = "efs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks_pv.id
    directoryPerms   = "700"
  }
}

