<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\WageResource;
use App\Repositories\WageRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WageController extends Controller
{
    public function __construct(private readonly WageRepository $repository) {}

    public function index(Request $request): JsonResponse
    {
        return WageResource::collection(
            $this->repository->paginate($request->only(['employee_id', 'company_id', 'year', 'month']))
        )->response();
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'employee_id' => ['required', 'exists:employees,id'],
            'company_id' => ['required', 'exists:companies,id'],
            'year' => ['required', 'integer'],
            'month' => ['required', 'integer', 'between:1,12'],
            'hourly_rate' => ['nullable', 'numeric'],
            'daily_rate' => ['nullable', 'numeric'],
            'days_worked' => ['nullable', 'integer'],
            'hours_worked' => ['nullable', 'integer'],
            'gross_amount' => ['nullable', 'numeric'],
            'deductions' => ['nullable', 'numeric'],
            'net_amount' => ['nullable', 'numeric'],
            'status' => ['nullable', 'in:draft,approved,paid'],
        ]);

        return (new WageResource($this->repository->create($data)->load('employee')))->response()->setStatusCode(201);
    }

    public function show(int $id): JsonResponse
    {
        return response()->json(['data' => new WageResource($this->repository->findOrFail($id))]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'hourly_rate' => ['nullable', 'numeric'],
            'daily_rate' => ['nullable', 'numeric'],
            'days_worked' => ['nullable', 'integer'],
            'hours_worked' => ['nullable', 'integer'],
            'gross_amount' => ['nullable', 'numeric'],
            'deductions' => ['nullable', 'numeric'],
            'net_amount' => ['nullable', 'numeric'],
            'status' => ['nullable', 'in:draft,approved,paid'],
        ]);

        return response()->json([
            'data' => new WageResource($this->repository->update($id, $data)->load('employee')),
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $this->repository->delete($id);

        return response()->json(['message' => 'Deleted']);
    }
}
