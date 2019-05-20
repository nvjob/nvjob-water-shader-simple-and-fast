# NVJOB Water Shader - simple and fast.

Version 1.4.1

Simple and fast water shader. This shader is suitable for scenes where water is not a key element of the scene, but a decorative element. Supported rendering path deferred and forward.

![GitHub Logo](https://lh3.googleusercontent.com/FtJ2jlK_x44Ck3H5dIm5bHzsuk6azmb74QTCctWrAeUFDp4qIpffIISW5XPfieR6ElYfVIZe3N4y1nUDQT_0h7fdsnezQ-DdNtj3lknTpXmQQij8PWPvVi-ZlQQut80Mb57H9s8nS8zT4U_v2MTGcQs51MJx1YKRPxtRrZAXEg7StUWvQooy3xSz4TP1hcgF-vpBE0w9Bvk9Vg5mnmAg4sbZOz708ZXYB2UL4jKxdTRLy3ImsYCt06mOMJ3Q7t33d_ZDqY-N19rim4ZQx59JhEEzcC5EfUpGK3qGesyq3uHGHIa9_L5A_P_5_2TOHcOi0JPF7dRK_sicEL4PQRduZLd2BMXDr3radFJl6ZjnC32i_UzL2F83jkOto9wA0hVIsDe0v27WwRGfgmNOh3nvC1kIul-0b3K-7ksj8tRtQYmOqXjM6PSbkfu99wl24bbbd8L-iybX8Qtxn9VwGgNFRh0ZcP7pCjzCeehA41f8EfonznvKs_ihKXeiexEyX1Y_HOCwVy-t0GITLln6UjjBPpMB_LxpEzQHF2u_hs_lwnKie2o6TR7T42BIq42mcmZb7_ucqzq7c_8k7EcffDN982fecqdWOfb3c77BfGAjtBiDybMEVSe20-WZL-goXbx9pdx2RVOqu2dLp_E7HJtVk1WvoqfxQc50o8mqeWqfVizpfOysCkLXKF9hJX6tQL1R26nROHM8Cqyy6A5vX8kE-9Is=w1636-h916-no)

![GitHub Logo](https://lh3.googleusercontent.com/YslObkHcSacVWd-8PWRIj3plwJFu_loHQiriS81Gy3fQZ3uukjBuK0EuOLlWEdaNKrq6BkEzDyGHvN6TvUwv1-HUhWlU4yuEhGazNyIoswIotVqF0DEa-WlZjKAHO0a5jG5XSa9MbZV3CkFYuBJzzXjpc0aXUC8HIcrPKRtiRvPEEOnmH5PTI956OFd8YZ82WvQNPa80wy1sDJDVBIAhMgadrw4JXJ6LME7VtX4-je97LBa7u6GXyzSTXD3xlARUemnQ48FLfqgibGWQJYSA7MKl39LPbFMMxSpIXRohw6ranmMbAXJP16MqbBOfLv1Xy2ERiMViMCem1nptIp6XRnXIZ5IUgyCgh84nXHCkRm4GG0eJJv66tYo6Z3dHy589TUkBDHlL3yrCcHx55E2WCwtVM91xAWhyCntxP31LBaV2hAkw4nKa0DPZWU545tX1IrvnXC7L231nnLOQrNYIpGRbG7T5MfqBGWQQeQulIIlOCgxCOc_OsUJQcTdEevlopCQTMPpHVrunO-Ht0NJpNBtb4j8wGNFTcl5tk3aq2lJfxk_WXbD88pSdwVloK3jDcVW2IZ5mnyB9IuK_bYRHyeSZ0t8oSewDKeUlbIOpoWUyNRN-6IA9oXqf3mBvTqsLz1KbLPfjW-JNvXv-OHfrnlpKzFLdX6X623GXz5hHZ3-DpseDZXj8D_bpJLFPwriUHgOZ8IRPv_lcHCgwF18Cmygu=w1636-h916-no)

------------------------------------

### Prerequisites

To work on the project, you will need a Unity version of at least 2019.1.0f2 (64-bit).

### Information

The movement of the waves is carried out using global shader variables: _WaterLocalUvX, _WaterLocalUvZ, _WaterLocalUvNX, _WaterLocalUvNZ.

_WaterLocalUvX, _WaterLocalUvZ - Offset main texture.

_WaterLocalUvNX, _WaterLocalUvNZ - Offset normal map texture.


![GitHub Logo](https://lh3.googleusercontent.com/zpGEbAfdPEVf2EJH4om8x7kGZik0Wl8xOl3SKyhm7bBmcT2S0SdUtiPlV-mBkHs7JXNI2Lu2JqUGx7-_G_eU4Qza4z2uWLYtH7PBH8JXzb4TLWZMqsSmRexXFqaeQJoJYL8Bp8StncFEDV8f6kjHz4zDtILshcVgWpwhWN8Z6I-nUq1Csu6FSmB-lnFCFLhDwglf_NZmQf9RQYSFjNWDBbiAqOT6c3rNAySAmHiGf5xija_0Rf0sVZu81wv64ZOP3Bmsh_e78l3i-lwhwj43G0F9fE6ZYETv_QkmpIHfMTBwKl7dNgXXOG8MOpJ-ua18VxDHp4-zp1qI0CLk5xsRvINxam3ROGUEARFvBh9Qm3nDOeNRE-U_ogePPEcpiZ0HXF-qS9-N4oDqUVp7wjCazbTdaYzDsBjSjyzXZdtl9A0BicG5JrI3HTpjuxkRLrjaQytmfUBcK1N9xTWSJcpS0WUoLo9R4ufOFMub6hsw-H1pfc3qL5vxP4FLDKFQ2eujsnSYKackT78w16uUpTdZhpPHFdZGDrXM8rizcrW0khThGC-OhN0yk0CjyvUShWRN9ikFZE1Mmv9UE8Oz7lBgf-gCZUL3OuUeCCEYSRkIgDaYxSwfTsGgtvGUrUCljRxMEIOBaPaNYjPCWKRgbWFOGt19I-5uItl1v3zfdLVu8ZIHYXhIf3ZNjUMPLMYnj_nB7ve7l1Q88Z9AgTvXAPNiLiEv=w383-h859-no)

------------------------------------

### Authors
Designed by #NVJOB Nicholas Veselov | https://nvjob.pro | http://nvjob.dx.am | https://twitter.com/nvjob

### License
This project is licensed under the MIT License - see the LICENSE file for details
