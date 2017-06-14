from django.http import JsonResponse

from app_business_logic import fetch_value


def echo(request, ident):
    return JsonResponse({'value': ident})


def network(request, ident):
    response = fetch_value(ident)
    return JsonResponse(response)
