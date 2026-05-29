<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Company\StoreCompanyRequest;
use App\Http\Requests\Company\UpdateCompanyRequest;
use App\Http\Resources\CompanyResource;
use App\Repositories\CompanyRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CompanyController extends Controller
{
    public function __construct(private readonly CompanyRepository $repository) {}

    public function index(Request $request): JsonResponse
    {
        $items = $this->repository->paginate($request->only(['search', 'is_active']));

        return CompanyResource::collection($items)->response();
    }

    public function store(StoreCompanyRequest $request): JsonResponse
    {
        $company = $this->repository->create($request->validated());

        return (new CompanyResource($company))->response()->setStatusCode(201);
    }

    public function show(int $company): JsonResponse
    {
        return response()->json(['data' => new CompanyResource($this->repository->findOrFail($company))]);
    }

    public function update(UpdateCompanyRequest $request, int $company): JsonResponse
    {
        $record = $this->repository->update($company, $request->validated());

        return response()->json(['data' => new CompanyResource($record)]);
    }

    public function destroy(int $company): JsonResponse
    {
        $this->repository->delete($company);

        return response()->json(['message' => 'Deleted']);
    }
}
