from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
#    path('api/MetricsData/<int:date>', views.metrics_data, name='metrics_data'),
    path('MetricsData/<int:date>', views.MetricsDataView.as_view(), name='get_metrics_data'),
    path('MetricsData/', views.MetricsDataView.as_view(), name='update_metrics_data'),
]