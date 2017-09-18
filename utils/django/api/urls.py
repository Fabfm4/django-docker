# -*- coding: utf-8 -*-
from django.conf import settings
from django.conf.urls import include, url
from rest_framework_swagger.views import get_swagger_view

schema_view = get_swagger_view(title='${PROJECT_NAME} API')

urlpatterns = [
    url(
        r'^v1/', include('${PROJECT_NAME}.api.v1.urls', namespace='v1')
    ),
]

if not settings.PRODUCTION:
    urlpatterns += [
        url(
            r'^docs/', schema_view
        ),
    ]
