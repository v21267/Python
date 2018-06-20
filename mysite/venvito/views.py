from django.http import HttpResponse, JsonResponse
from django.views.generic import View
from django.views.decorators.csrf import csrf_exempt
import json
import datetime

from . import db_helper

def index(request):
    return HttpResponse("Hello, world. You're at the Venvito index.")

class MetricsDataView(View):

    def get(self, request, *args, **kwargs):
        date = kwargs["date"]
        data = db_helper.DbHelper.run_query_sp("fn_get_metrics_data", (date,))
    #    print(data)
        response = JsonResponse(data, safe=False)
        return response

    @csrf_exempt
    def post(self, request, *args, **kwargs):
        body = request.body.decode('utf-8')
        data = json.loads(body)
        db_helper.DbHelper.execute_sp( \
            "fn_set_metrics_data", \
            (data["date"], data["code"], data["value"], ))
    #    print(data)
        response = JsonResponse({"ok": 1}, safe=False)
        return response

class MetricsChartView(View):

    def get(self, request, *args, **kwargs):
        date_range = kwargs["date_range"]
        date = datetime.datetime.today().strftime('%Y%m%d')
        metrics = db_helper.DbHelper.run_query_sp("fn_get_metrics_data", (date,))
        for metric in metrics:
            code = metric["code"]
            chartData = db_helper.DbHelper.run_query_sp("fn_get_chart_data", (date_range, code,))
            metric["chartData"] = chartData
            metric["totalValue"] = sum(item["value"] for item in chartData)
    #    print(metrics)
        response = JsonResponse(metrics, safe=False)
        return response
