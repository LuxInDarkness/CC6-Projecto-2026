from .contracts import Contracts
from .integrations import ExternalSystems


class DiscographyContractAdminProxy(
    Contracts
):
    class Meta:
        proxy = True
        verbose_name = "Discography Contract"
        verbose_name_plural = "Discography Contracts"


class ManufacturingContractAdminProxy(
    Contracts
):
    class Meta:
        proxy = True
        verbose_name = "Manufacturing Contract"
        verbose_name_plural = "Manufacturing Contracts"


class DiscographyIntegrationConsole(
    ExternalSystems
):
    class Meta:
        proxy = True
        verbose_name = "Discography Console"
        verbose_name_plural = "Discography Console"


class ManufacturingIntegrationConsole(
    ExternalSystems
):
    class Meta:
        proxy = True
        verbose_name = "Manufacturing Console"
        verbose_name_plural = "Manufacturing Console"