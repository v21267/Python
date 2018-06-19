from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('MetricsData/<int:date>', views.metrics_data, name='metrics_data'),
]