# $NetBSD$

BUILDLINK_TREE+=	tpm2-tss

.if !defined(TPM2_TSS_BUILDLINK3_MK)
TPM2_TSS_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.tpm2-tss+=	tpm2-tss>=4.0.1
BUILDLINK_PKGSRCDIR.tpm2-tss?=		../../sysutils/tpm2-tss

.include "../../security/openssl/buildlink3.mk"
.include "../../textproc/json-c/buildlink3.mk"
.include "../../www/curl/buildlink3.mk"
.include "../../devel/libuuid/buildlink3.mk"
.endif	# TPM2_TSS_BUILDLINK3_MK

BUILDLINK_TREE+=	-tpm2-tss
