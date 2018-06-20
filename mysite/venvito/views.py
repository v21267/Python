from django.http import HttpResponse, JsonResponse
from django.views.generic import View
from django.views.decorators.csrf import csrf_exempt
import json

from . import db_helper

def index(request):
    return HttpResponse("Hello, world. You're at the Venvito index.")

def metrics_data(request, date):
    s = str(date)
    data = db_helper.DbHelper.run_query_sp("fn_get_metrics_data", (s,))
#    print(data)
    response = JsonResponse(data, safe=False)
    return response

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
