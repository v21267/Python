from django.http import HttpResponse, JsonResponse
from . import db_helper

def index(request):
    return HttpResponse("Hello, world. You're at the Venvito index.")

def metrics_data(request, date):
    s = str(date)
#    s = s[:4] + "/" + s[4:6] + "/" + s[6:]
    data = db_helper.DbHelper.run_query_sp("fn_get_metrics_data", (s,))
    print(data)
    response = JsonResponse(data, safe=False)
    return response