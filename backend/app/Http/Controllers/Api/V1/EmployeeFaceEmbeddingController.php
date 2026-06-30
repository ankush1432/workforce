<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\EmployeeFaceEmbeddingResource;
use App\Models\EmployeeFaceEmbedding;
use App\Repositories\EmployeeRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EmployeeFaceEmbeddingController extends Controller
{
    public function __construct(
        private readonly EmployeeRepository $employeeRepository,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = EmployeeFaceEmbedding::with(['employee.department', 'employee.designation', 'employee.supervisor', 'registeredBy'])
            ->where('is_primary', true)
            ->orderBy('registered_at', 'desc');

        if ($request->has('employee_id')) {
            $query->where('employee_id', $request->input('employee_id'));
        }

        $embeddings = $query->paginate($request->input('per_page', 20));

        return EmployeeFaceEmbeddingResource::collection($embeddings)->response();
    }

    public function show(int $id): JsonResponse
    {
        $embedding = EmployeeFaceEmbedding::with(['employee.department', 'employee.designation', 'employee.supervisor', 'registeredBy'])
            ->findOrFail($id);

        return (new EmployeeFaceEmbeddingResource($embedding))->response();
    }
}
